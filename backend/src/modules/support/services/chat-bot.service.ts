import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ChatBotRule, ChatBotRuleDocument } from '../schemas/chat-bot-rule.schema';
import { ChatSession } from '../schemas/chat-session.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🤖 Chat Bot Service - خدمة البوت
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class ChatBotService {
    private readonly logger = new Logger(ChatBotService.name);

    constructor(
        @InjectModel(ChatBotRule.name) private botRuleModel: Model<ChatBotRuleDocument>,
    ) { }

    /**
     * Process message and find matching bot response
     */
    async processMessage(message: string, session: ChatSession, language: 'ar' | 'en' = 'ar'): Promise<{
        shouldRespond: boolean;
        response?: string;
        quickReplies?: Array<{ label: string; value: string; action: string }>;
        matchedRule?: ChatBotRule;
    }> {
        try {
            const normalizedMessage = message.toLowerCase().trim();

            // Get all active rules sorted by priority
            const rules = await this.botRuleModel
                .find({ isActive: true })
                .sort({ priority: -1 })
                .exec();

            // Find matching rule
            for (const rule of rules) {
                const matched = rule.triggerPatterns.some((pattern) => {
                    try {
                        const regex = new RegExp(pattern, 'i');
                        return regex.test(normalizedMessage);
                    } catch (error) {
                        // If pattern is not valid regex, try exact match
                        return normalizedMessage.includes(pattern.toLowerCase());
                    }
                });

                if (matched) {
                    // Update usage count
                    await this.botRuleModel.findByIdAndUpdate(rule._id, {
                        $inc: { usageCount: 1 },
                        lastUsedAt: new Date(),
                    });

                    // Format quick replies
                    const quickReplies = rule.quickReplies.map((qr) => ({
                        label: language === 'ar' ? qr.labelAr : qr.labelEn,
                        value: qr.value,
                        action: qr.action,
                    }));

                    return {
                        shouldRespond: true,
                        response: language === 'ar' ? rule.responseAr : rule.responseEn,
                        quickReplies: quickReplies.length > 0 ? quickReplies : undefined,
                        matchedRule: rule,
                    };
                }
            }

            return { shouldRespond: false };
        } catch (error) {
            this.logger.error('Bot processing error:', error);
            return { shouldRespond: false };
        }
    }

    /**
     * Get all bot rules
     */
    async getAllRules(categoryId?: string): Promise<ChatBotRule[]> {
        const query: any = { isActive: true };
        if (categoryId) {
            query.category = new Types.ObjectId(categoryId);
        }
        return this.botRuleModel.find(query).sort({ priority: -1 }).exec();
    }

    /**
     * Create bot rule
     */
    async createRule(data: Partial<ChatBotRule>): Promise<ChatBotRule> {
        return this.botRuleModel.create(data);
    }

    /**
     * Update bot rule
     */
    async updateRule(id: string, data: Partial<ChatBotRule>): Promise<ChatBotRule> {
        const rule = await this.botRuleModel.findByIdAndUpdate(id, data, { new: true });
        if (!rule) throw new Error('Bot rule not found');
        return rule;
    }

    /**
     * Delete bot rule
     */
    async deleteRule(id: string): Promise<void> {
        await this.botRuleModel.findByIdAndDelete(id);
    }

    /**
     * Seed default bot rules
     */
    async seedDefaultRules(): Promise<void> {
        const existing = await this.botRuleModel.countDocuments();
        if (existing > 0) return;

        const defaultRules = [
            {
                nameAr: 'ترحيب',
                nameEn: 'Greeting',
                triggerPatterns: ['مرحبا', 'السلام عليكم', 'hello', 'hi', 'hey'],
                responseAr: 'مرحباً بك! كيف يمكنني مساعدتك اليوم؟',
                responseEn: 'Hello! How can I help you today?',
                priority: 10,
                quickReplies: [
                    {
                        labelAr: 'استفسار عن طلب',
                        labelEn: 'Order inquiry',
                        value: 'order_inquiry',
                        action: 'reply',
                    },
                    {
                        labelAr: 'مشكلة في منتج',
                        labelEn: 'Product issue',
                        value: 'product_issue',
                        action: 'reply',
                    },
                    {
                        labelAr: 'التحدث مع وكيل',
                        labelEn: 'Talk to agent',
                        value: 'transfer_agent',
                        action: 'transfer',
                    },
                ],
            },
            {
                nameAr: 'تتبع الطلب',
                nameEn: 'Order Tracking',
                triggerPatterns: ['تتبع', 'طلبي', 'أين طلبي', 'track', 'my order', 'where is my order'],
                responseAr: 'يمكنك تتبع طلبك من خلال قسم "طلباتي" في التطبيق. هل تحتاج مساعدة في شيء آخر؟',
                responseEn: 'You can track your order from the "My Orders" section in the app. Do you need help with anything else?',
                priority: 8,
            },
            {
                nameAr: 'ساعات العمل',
                nameEn: 'Working Hours',
                triggerPatterns: ['ساعات العمل', 'متى تفتحون', 'working hours', 'opening hours', 'when open'],
                responseAr: 'نحن متاحون من الأحد إلى الخميس من 9 صباحاً حتى 6 مساءً. هل يمكنني مساعدتك في شيء آخر؟',
                responseEn: 'We are available Sunday to Thursday from 9 AM to 6 PM. Can I help you with anything else?',
                priority: 5,
            },
            {
                nameAr: 'شكر',
                nameEn: 'Thanks',
                triggerPatterns: ['شكرا', 'شكراً', 'thank you', 'thanks'],
                responseAr: 'العفو! سعداء بخدمتك. لا تتردد في التواصل معنا إذا احتجت أي مساعدة.',
                responseEn: "You're welcome! Happy to help. Don't hesitate to contact us if you need any assistance.",
                priority: 3,
            },
        ];

        await this.botRuleModel.insertMany(defaultRules);
        this.logger.log('Default bot rules seeded');
    }
}
