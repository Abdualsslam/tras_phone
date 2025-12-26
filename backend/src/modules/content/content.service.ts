import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { FaqCategory, FaqCategoryDocument } from './schemas/faq-category.schema';
import { Faq, FaqDocument } from './schemas/faq.schema';
import { Page, PageDocument, PageStatus } from './schemas/page.schema';
import { Banner, BannerDocument, BannerPosition, BannerType } from './schemas/banner.schema';
import { Slider, SliderDocument } from './schemas/slider.schema';
import { Testimonial, TestimonialDocument } from './schemas/testimonial.schema';

@Injectable()
export class ContentService {
    constructor(
        @InjectModel(FaqCategory.name) private faqCategoryModel: Model<FaqCategoryDocument>,
        @InjectModel(Faq.name) private faqModel: Model<FaqDocument>,
        @InjectModel(Page.name) private pageModel: Model<PageDocument>,
        @InjectModel(Banner.name) private bannerModel: Model<BannerDocument>,
        @InjectModel(Slider.name) private sliderModel: Model<SliderDocument>,
        @InjectModel(Testimonial.name) private testimonialModel: Model<TestimonialDocument>,
    ) { }

    // ==================== FAQ Categories ====================

    async createFaqCategory(data: Partial<FaqCategory>): Promise<FaqCategory> {
        return this.faqCategoryModel.create(data);
    }

    async findAllFaqCategories(activeOnly: boolean = true): Promise<FaqCategory[]> {
        const query = activeOnly ? { isActive: true } : {};
        return this.faqCategoryModel.find(query).sort({ sortOrder: 1 }).exec();
    }

    async updateFaqCategory(id: string, data: Partial<FaqCategory>): Promise<FaqCategory> {
        const category = await this.faqCategoryModel.findByIdAndUpdate(id, data, { new: true });
        if (!category) throw new NotFoundException('Category not found');
        return category;
    }

    // ==================== FAQs ====================

    async createFaq(data: Partial<Faq>, createdBy?: string): Promise<Faq> {
        const faq = await this.faqModel.create({
            ...data,
            createdBy: createdBy ? new Types.ObjectId(createdBy) : undefined,
        });

        await this.faqCategoryModel.findByIdAndUpdate(data.category, {
            $inc: { faqCount: 1 },
        });

        return faq;
    }

    async findFaqsByCategory(categorySlug: string): Promise<Faq[]> {
        const category = await this.faqCategoryModel.findOne({ slug: categorySlug, isActive: true });
        if (!category) throw new NotFoundException('Category not found');

        return this.faqModel
            .find({ category: category._id, isActive: true })
            .sort({ sortOrder: 1 })
            .exec();
    }

    async findAllFaqs(activeOnly: boolean = true): Promise<any[]> {
        const query = activeOnly ? { isActive: true } : {};
        const faqs = await this.faqModel
            .find(query)
            .populate('category', 'nameAr nameEn slug')
            .sort({ sortOrder: 1 })
            .exec();
        return faqs;
    }

    async searchFaqs(searchTerm: string): Promise<Faq[]> {
        return this.faqModel
            .find({
                isActive: true,
                $text: { $search: searchTerm },
            })
            .limit(20)
            .exec();
    }

    async updateFaq(id: string, data: Partial<Faq>, updatedBy?: string): Promise<Faq> {
        const faq = await this.faqModel.findByIdAndUpdate(
            id,
            { ...data, updatedBy: updatedBy ? new Types.ObjectId(updatedBy) : undefined },
            { new: true }
        );
        if (!faq) throw new NotFoundException('FAQ not found');
        return faq;
    }

    async incrementFaqView(id: string): Promise<void> {
        await this.faqModel.findByIdAndUpdate(id, { $inc: { viewCount: 1 } });
    }

    async markFaqHelpful(id: string, helpful: boolean): Promise<void> {
        const update = helpful
            ? { $inc: { helpfulCount: 1 } }
            : { $inc: { notHelpfulCount: 1 } };
        await this.faqModel.findByIdAndUpdate(id, update);
    }

    // ==================== Pages ====================

    async createPage(data: Partial<Page>, createdBy?: string): Promise<Page> {
        return this.pageModel.create({
            ...data,
            createdBy: createdBy ? new Types.ObjectId(createdBy) : undefined,
        });
    }

    async findPageBySlug(slug: string): Promise<Page> {
        const page = await this.pageModel.findOne({
            slug,
            status: PageStatus.PUBLISHED
        });
        if (!page) throw new NotFoundException('Page not found');

        // Increment view count
        await this.pageModel.findByIdAndUpdate(page._id, { $inc: { viewCount: 1 } });

        return page;
    }

    async findAllPages(status?: PageStatus): Promise<Page[]> {
        const query: any = {};
        if (status) query.status = status;
        return this.pageModel.find(query).sort({ createdAt: -1 }).exec();
    }

    async findFooterPages(): Promise<Page[]> {
        return this.pageModel
            .find({ showInFooter: true, status: PageStatus.PUBLISHED })
            .select('titleAr titleEn slug')
            .sort({ sortOrder: 1 })
            .exec();
    }

    async findHeaderPages(): Promise<Page[]> {
        return this.pageModel
            .find({ showInHeader: true, status: PageStatus.PUBLISHED })
            .select('titleAr titleEn slug')
            .sort({ sortOrder: 1 })
            .exec();
    }

    async updatePage(id: string, data: Partial<Page>, updatedBy?: string): Promise<Page> {
        const updateData: any = {
            ...data,
            updatedBy: updatedBy ? new Types.ObjectId(updatedBy) : undefined,
        };

        // Handle publish
        if (data.status === PageStatus.PUBLISHED) {
            updateData.publishedAt = new Date();
            updateData.publishedBy = updatedBy ? new Types.ObjectId(updatedBy) : undefined;
        }

        const page = await this.pageModel.findByIdAndUpdate(id, updateData, { new: true });
        if (!page) throw new NotFoundException('Page not found');
        return page;
    }

    async deletePage(id: string): Promise<void> {
        const result = await this.pageModel.findByIdAndDelete(id);
        if (!result) throw new NotFoundException('Page not found');
    }

    // ==================== Banners ====================

    async createBanner(data: Partial<Banner>, createdBy?: string): Promise<Banner> {
        return this.bannerModel.create({
            ...data,
            createdBy: createdBy ? new Types.ObjectId(createdBy) : undefined,
        });
    }

    async findActiveBanners(position: BannerPosition): Promise<Banner[]> {
        const now = new Date();
        return this.bannerModel
            .find({
                position,
                isActive: true,
                $or: [
                    { startDate: { $exists: false } },
                    { startDate: { $lte: now } },
                ],
                $and: [
                    {
                        $or: [
                            { endDate: { $exists: false } },
                            { endDate: { $gte: now } },
                        ],
                    },
                ],
            })
            .sort({ priority: -1, sortOrder: 1 })
            .exec();
    }

    async findAllBanners(type?: BannerType): Promise<Banner[]> {
        const query: any = {};
        if (type) query.type = type;
        return this.bannerModel.find(query).sort({ createdAt: -1 }).exec();
    }

    async updateBanner(id: string, data: Partial<Banner>): Promise<Banner> {
        const banner = await this.bannerModel.findByIdAndUpdate(id, data, { new: true });
        if (!banner) throw new NotFoundException('Banner not found');
        return banner;
    }

    async recordBannerImpression(id: string): Promise<void> {
        await this.bannerModel.findByIdAndUpdate(id, { $inc: { impressions: 1 } });
    }

    async recordBannerClick(id: string): Promise<void> {
        await this.bannerModel.findByIdAndUpdate(id, { $inc: { clicks: 1 } });
    }

    async deleteBanner(id: string): Promise<void> {
        const result = await this.bannerModel.findByIdAndDelete(id);
        if (!result) throw new NotFoundException('Banner not found');
    }

    // ==================== Sliders ====================

    async createSlider(data: Partial<Slider>, createdBy?: string): Promise<Slider> {
        return this.sliderModel.create({
            ...data,
            createdBy: createdBy ? new Types.ObjectId(createdBy) : undefined,
        });
    }

    async findSliderBySlug(slug: string): Promise<Slider> {
        const slider = await this.sliderModel.findOne({ slug, isActive: true });
        if (!slider) throw new NotFoundException('Slider not found');
        return slider;
    }

    async findSlidersByLocation(location: string): Promise<Slider[]> {
        return this.sliderModel.find({ location, isActive: true }).exec();
    }

    async findAllSliders(): Promise<Slider[]> {
        return this.sliderModel.find().sort({ createdAt: -1 }).exec();
    }

    async updateSlider(id: string, data: Partial<Slider>): Promise<Slider> {
        const slider = await this.sliderModel.findByIdAndUpdate(id, data, { new: true });
        if (!slider) throw new NotFoundException('Slider not found');
        return slider;
    }

    async addSlide(sliderId: string, slide: any): Promise<Slider> {
        const slider = await this.sliderModel.findByIdAndUpdate(
            sliderId,
            { $push: { slides: slide } },
            { new: true }
        );
        if (!slider) throw new NotFoundException('Slider not found');
        return slider;
    }

    async updateSlide(sliderId: string, slideIndex: number, slide: any): Promise<Slider> {
        const slider = await this.sliderModel.findById(sliderId);
        if (!slider) throw new NotFoundException('Slider not found');

        slider.slides[slideIndex] = { ...slider.slides[slideIndex], ...slide };
        return slider.save();
    }

    async removeSlide(sliderId: string, slideIndex: number): Promise<Slider> {
        const slider = await this.sliderModel.findById(sliderId);
        if (!slider) throw new NotFoundException('Slider not found');

        slider.slides.splice(slideIndex, 1);
        return slider.save();
    }

    async deleteSlider(id: string): Promise<void> {
        const result = await this.sliderModel.findByIdAndDelete(id);
        if (!result) throw new NotFoundException('Slider not found');
    }

    // ==================== Testimonials ====================

    async createTestimonial(data: Partial<Testimonial>): Promise<Testimonial> {
        return this.testimonialModel.create(data);
    }

    async findActiveTestimonials(limit: number = 10): Promise<Testimonial[]> {
        return this.testimonialModel
            .find({ isActive: true })
            .sort({ isFeatured: -1, sortOrder: 1 })
            .limit(limit)
            .exec();
    }

    async findFeaturedTestimonials(): Promise<Testimonial[]> {
        return this.testimonialModel
            .find({ isActive: true, isFeatured: true })
            .sort({ sortOrder: 1 })
            .limit(6)
            .exec();
    }

    async findAllTestimonials(): Promise<Testimonial[]> {
        return this.testimonialModel.find().sort({ createdAt: -1 }).exec();
    }

    async updateTestimonial(id: string, data: Partial<Testimonial>): Promise<Testimonial> {
        const testimonial = await this.testimonialModel.findByIdAndUpdate(id, data, { new: true });
        if (!testimonial) throw new NotFoundException('Testimonial not found');
        return testimonial;
    }

    async approveTestimonial(id: string, approvedBy: string): Promise<Testimonial> {
        const testimonial = await this.testimonialModel.findByIdAndUpdate(
            id,
            {
                isActive: true,
                approvedBy: new Types.ObjectId(approvedBy),
                approvedAt: new Date(),
            },
            { new: true }
        );

        if (!testimonial) throw new NotFoundException('Testimonial not found');
        return testimonial;
    }

    async deleteTestimonial(id: string): Promise<void> {
        const result = await this.testimonialModel.findByIdAndDelete(id);
        if (!result) throw new NotFoundException('Testimonial not found');
    }

    // ==================== Seeding ====================

    async seedDefaultContent(): Promise<void> {
        // Seed FAQ Categories
        const faqCategoryCount = await this.faqCategoryModel.countDocuments();
        if (faqCategoryCount === 0) {
            const categories = [
                { nameAr: 'الطلبات والشحن', nameEn: 'Orders & Shipping', slug: 'orders-shipping', icon: 'truck', sortOrder: 1 },
                { nameAr: 'المدفوعات', nameEn: 'Payments', slug: 'payments', icon: 'credit-card', sortOrder: 2 },
                { nameAr: 'المرتجعات والاستبدال', nameEn: 'Returns & Exchange', slug: 'returns-exchange', icon: 'refresh-cw', sortOrder: 3 },
                { nameAr: 'الحساب والعضوية', nameEn: 'Account & Membership', slug: 'account', icon: 'user', sortOrder: 4 },
                { nameAr: 'المنتجات والضمان', nameEn: 'Products & Warranty', slug: 'products-warranty', icon: 'shield', sortOrder: 5 },
            ];
            await this.faqCategoryModel.insertMany(categories);
        }

        // Seed essential pages
        const pageCount = await this.pageModel.countDocuments();
        if (pageCount === 0) {
            const pages = [
                {
                    titleAr: 'سياسة الخصوصية',
                    titleEn: 'Privacy Policy',
                    slug: 'privacy-policy',
                    type: 'policy',
                    contentAr: 'سياسة الخصوصية الخاصة بنا...',
                    contentEn: 'Our privacy policy...',
                    status: PageStatus.PUBLISHED,
                    showInFooter: true,
                    sortOrder: 1,
                },
                {
                    titleAr: 'الشروط والأحكام',
                    titleEn: 'Terms & Conditions',
                    slug: 'terms-conditions',
                    type: 'policy',
                    contentAr: 'شروط وأحكام الاستخدام...',
                    contentEn: 'Terms and conditions of use...',
                    status: PageStatus.PUBLISHED,
                    showInFooter: true,
                    sortOrder: 2,
                },
                {
                    titleAr: 'سياسة الشحن والتوصيل',
                    titleEn: 'Shipping Policy',
                    slug: 'shipping-policy',
                    type: 'policy',
                    contentAr: 'سياسة الشحن والتوصيل...',
                    contentEn: 'Shipping and delivery policy...',
                    status: PageStatus.PUBLISHED,
                    showInFooter: true,
                    sortOrder: 3,
                },
                {
                    titleAr: 'سياسة الإرجاع والاستبدال',
                    titleEn: 'Return Policy',
                    slug: 'return-policy',
                    type: 'policy',
                    contentAr: 'سياسة الإرجاع والاستبدال...',
                    contentEn: 'Return and exchange policy...',
                    status: PageStatus.PUBLISHED,
                    showInFooter: true,
                    sortOrder: 4,
                },
                {
                    titleAr: 'من نحن',
                    titleEn: 'About Us',
                    slug: 'about-us',
                    type: 'about',
                    contentAr: 'معلومات عنا...',
                    contentEn: 'About our company...',
                    status: PageStatus.PUBLISHED,
                    showInFooter: true,
                    showInHeader: true,
                    sortOrder: 5,
                },
                {
                    titleAr: 'اتصل بنا',
                    titleEn: 'Contact Us',
                    slug: 'contact-us',
                    type: 'static',
                    contentAr: 'معلومات التواصل...',
                    contentEn: 'Contact information...',
                    status: PageStatus.PUBLISHED,
                    showInFooter: true,
                    showInHeader: true,
                    sortOrder: 6,
                },
            ];
            await this.pageModel.insertMany(pages);
        }
    }
}
