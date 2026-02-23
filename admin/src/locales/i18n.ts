import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import ar from './ar.json';
import en from './en.json';

const savedLanguage = localStorage.getItem('language') || 'ar';

i18n.use(initReactI18next).init({
    resources: {
        ar: { translation: ar },
        en: { translation: en },
    },
    lng: savedLanguage,
    fallbackLng: 'ar',
    interpolation: {
        escapeValue: false,
    },
});

// Update document direction based on language
export const updateDocumentDirection = (lang: string) => {
    document.documentElement.dir = i18n.dir(lang);
    document.documentElement.lang = lang;
    localStorage.setItem('language', lang);
};

// Initialize direction
updateDocumentDirection(savedLanguage);

export default i18n;
