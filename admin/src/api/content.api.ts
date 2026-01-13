import apiClient from './client';
import type { ApiResponse } from '@/types';

// Helper function to extract data from nested API response
function extractData<T>(responseData: any): T {
    if (responseData && typeof responseData === 'object' && 'data' in responseData) {
        return responseData.data as T;
    }
    return responseData as T;
}

// Helper function to extract array data safely
function extractArrayData<T>(responseData: any): T[] {
    const data = extractData<T[] | T>(responseData);
    return Array.isArray(data) ? data : [];
}

// ══════════════════════════════════════════════════════════════
// Types
// ══════════════════════════════════════════════════════════════

export interface FaqCategory {
    _id: string;
    name: string;
    nameAr?: string;
    order: number;
    isActive: boolean;
}

export interface Faq {
    _id: string;
    categoryId: string;
    question: string;
    questionAr?: string;
    answer: string;
    answerAr?: string;
    order: number;
    isActive: boolean;
    views: number;
}

export interface Page {
    _id: string;
    slug: string;
    title: string;
    titleAr?: string;
    content: string;
    contentAr?: string;
    type: 'header' | 'footer' | 'other';
    isActive: boolean;
    createdAt: string;
    updatedAt: string;
}

export interface Banner {
    _id: string;
    title: string;
    titleAr?: string;
    imageUrl: string;
    linkUrl?: string;
    position: string;
    order: number;
    isActive: boolean;
    startDate?: string;
    endDate?: string;
    impressions: number;
    clicks: number;
}

export interface Slider {
    _id: string;
    name: string;
    nameAr?: string;
    isActive: boolean;
    slides: SliderSlide[];
}

export interface SliderSlide {
    _id: string;
    imageUrl: string;
    title?: string;
    titleAr?: string;
    subtitle?: string;
    subtitleAr?: string;
    linkUrl?: string;
    order: number;
}

export interface Testimonial {
    _id: string;
    customerName: string;
    customerTitle?: string;
    customerImage?: string;
    content: string;
    contentAr?: string;
    rating: number;
    isApproved: boolean;
    isFeatured: boolean;
    createdAt: string;
}

// ══════════════════════════════════════════════════════════════
// Content API
// ══════════════════════════════════════════════════════════════

export const contentApi = {
    // ─────────────────────────────────────────
    // FAQ Categories
    // ─────────────────────────────────────────

    getFaqCategories: async (): Promise<FaqCategory[]> => {
        const response = await apiClient.get<ApiResponse<FaqCategory[]>>('/content/faqs/categories');
        return extractArrayData<FaqCategory>(response.data.data);
    },

    createFaqCategory: async (data: Omit<FaqCategory, '_id'>): Promise<FaqCategory> => {
        const response = await apiClient.post<ApiResponse<FaqCategory>>('/content/admin/faqs/categories', data);
        return extractData<FaqCategory>(response.data.data);
    },

    updateFaqCategory: async (id: string, data: Partial<FaqCategory>): Promise<FaqCategory> => {
        const response = await apiClient.put<ApiResponse<FaqCategory>>(`/content/admin/faqs/categories/${id}`, data);
        return extractData<FaqCategory>(response.data.data);
    },

    // ─────────────────────────────────────────
    // FAQs
    // ─────────────────────────────────────────

    getFaqs: async (categoryId?: string): Promise<Faq[]> => {
        const response = await apiClient.get<ApiResponse<Faq[]>>('/content/faqs', {
            params: categoryId ? { categoryId } : undefined,
        });
        return extractArrayData<Faq>(response.data.data);
    },

    createFaq: async (data: Omit<Faq, '_id' | 'views'>): Promise<Faq> => {
        const response = await apiClient.post<ApiResponse<Faq>>('/content/admin/faqs', data);
        return extractData<Faq>(response.data.data);
    },

    updateFaq: async (id: string, data: Partial<Faq>): Promise<Faq> => {
        const response = await apiClient.put<ApiResponse<Faq>>(`/content/admin/faqs/${id}`, data);
        return extractData<Faq>(response.data.data);
    },

    deleteFaq: async (id: string): Promise<void> => {
        await apiClient.delete(`/content/admin/faqs/${id}`);
    },

    // ─────────────────────────────────────────
    // Pages
    // ─────────────────────────────────────────

    getPages: async (): Promise<Page[]> => {
        const response = await apiClient.get<ApiResponse<Page[]>>('/content/admin/pages');
        return extractArrayData<Page>(response.data.data);
    },

    getPage: async (id: string): Promise<Page> => {
        const response = await apiClient.get<ApiResponse<Page>>(`/content/admin/pages/${id}`);
        return extractData<Page>(response.data.data);
    },

    createPage: async (data: Omit<Page, '_id' | 'createdAt' | 'updatedAt'>): Promise<Page> => {
        const response = await apiClient.post<ApiResponse<Page>>('/content/admin/pages', data);
        return extractData<Page>(response.data.data);
    },

    updatePage: async (id: string, data: Partial<Page>): Promise<Page> => {
        const response = await apiClient.put<ApiResponse<Page>>(`/content/admin/pages/${id}`, data);
        return extractData<Page>(response.data.data);
    },

    deletePage: async (id: string): Promise<void> => {
        await apiClient.delete(`/content/admin/pages/${id}`);
    },

    // ─────────────────────────────────────────
    // Banners
    // ─────────────────────────────────────────

    getBanners: async (): Promise<Banner[]> => {
        const response = await apiClient.get<ApiResponse<Banner[]>>('/content/admin/banners');
        return extractArrayData<Banner>(response.data.data);
    },

    createBanner: async (data: Omit<Banner, '_id' | 'impressions' | 'clicks'>): Promise<Banner> => {
        const response = await apiClient.post<ApiResponse<Banner>>('/content/admin/banners', data);
        return extractData<Banner>(response.data.data);
    },

    updateBanner: async (id: string, data: Partial<Banner>): Promise<Banner> => {
        const response = await apiClient.put<ApiResponse<Banner>>(`/content/admin/banners/${id}`, data);
        return extractData<Banner>(response.data.data);
    },

    deleteBanner: async (id: string): Promise<void> => {
        await apiClient.delete(`/content/admin/banners/${id}`);
    },

    // ─────────────────────────────────────────
    // Sliders
    // ─────────────────────────────────────────

    getSliders: async (): Promise<Slider[]> => {
        const response = await apiClient.get<ApiResponse<Slider[]>>('/content/admin/sliders');
        return extractArrayData<Slider>(response.data.data);
    },

    createSlider: async (data: Omit<Slider, '_id' | 'slides'>): Promise<Slider> => {
        const response = await apiClient.post<ApiResponse<Slider>>('/content/admin/sliders', data);
        return extractData<Slider>(response.data.data);
    },

    updateSlider: async (id: string, data: Partial<Slider>): Promise<Slider> => {
        const response = await apiClient.put<ApiResponse<Slider>>(`/content/admin/sliders/${id}`, data);
        return extractData<Slider>(response.data.data);
    },

    addSlide: async (sliderId: string, slide: Omit<SliderSlide, '_id'>): Promise<Slider> => {
        const response = await apiClient.post<ApiResponse<Slider>>(`/content/admin/sliders/${sliderId}/slides`, slide);
        return extractData<Slider>(response.data.data);
    },

    updateSlide: async (sliderId: string, slideIndex: number, slide: Partial<SliderSlide>): Promise<Slider> => {
        const response = await apiClient.put<ApiResponse<Slider>>(`/content/admin/sliders/${sliderId}/slides/${slideIndex}`, slide);
        return extractData<Slider>(response.data.data);
    },

    removeSlide: async (sliderId: string, slideIndex: number): Promise<Slider> => {
        const response = await apiClient.delete<ApiResponse<Slider>>(`/content/admin/sliders/${sliderId}/slides/${slideIndex}`);
        return extractData<Slider>(response.data.data);
    },

    deleteSlider: async (id: string): Promise<void> => {
        await apiClient.delete(`/content/admin/sliders/${id}`);
    },

    // ─────────────────────────────────────────
    // FAQ Categories
    // ─────────────────────────────────────────

    deleteFaqCategory: async (id: string): Promise<void> => {
        await apiClient.delete(`/content/admin/faqs/categories/${id}`);
    },

    // ─────────────────────────────────────────
    // Testimonials
    // ─────────────────────────────────────────

    getTestimonials: async (): Promise<Testimonial[]> => {
        const response = await apiClient.get<ApiResponse<Testimonial[]>>('/content/admin/testimonials');
        return extractArrayData<Testimonial>(response.data.data);
    },

    createTestimonial: async (data: Omit<Testimonial, '_id' | 'createdAt'>): Promise<Testimonial> => {
        const response = await apiClient.post<ApiResponse<Testimonial>>('/content/admin/testimonials', data);
        return extractData<Testimonial>(response.data.data);
    },

    updateTestimonial: async (id: string, data: Partial<Testimonial>): Promise<Testimonial> => {
        const response = await apiClient.put<ApiResponse<Testimonial>>(`/content/admin/testimonials/${id}`, data);
        return extractData<Testimonial>(response.data.data);
    },

    approveTestimonial: async (id: string): Promise<Testimonial> => {
        const response = await apiClient.post<ApiResponse<Testimonial>>(`/content/admin/testimonials/${id}/approve`);
        return extractData<Testimonial>(response.data.data);
    },

    deleteTestimonial: async (id: string): Promise<void> => {
        await apiClient.delete(`/content/admin/testimonials/${id}`);
    },
};

export default contentApi;
