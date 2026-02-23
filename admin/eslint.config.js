import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import tseslint from 'typescript-eslint'
import { defineConfig, globalIgnores } from 'eslint/config'

const rtlGuardPlugin = {
  rules: {
    'no-physical-direction-classes': {
      meta: {
        type: 'problem',
        docs: {
          description:
            'Disallow physical direction classes in className (use logical start/end classes)',
        },
        schema: [],
      },
      create(context) {
        const restricted = /\b(?:ml-|mr-|pl-|pr-|text-left\b|text-right\b|float-left\b|float-right\b)/

        const checkClassNameValue = (node, value) => {
          if (!value || !restricted.test(value)) {
            return
          }

          context.report({
            node,
            message:
              'Avoid physical direction classes (ml/mr/pl/pr/text-left/text-right/float-*). Use logical classes like ms/me/ps/pe/text-start/text-end.',
          })
        }

        const getClassNameAttribute = (node) =>
          node.type === 'JSXAttribute' && node.name && node.name.name === 'className'

        return {
          JSXAttribute(node) {
            if (!getClassNameAttribute(node) || !node.value) {
              return
            }

            if (node.value.type === 'Literal' && typeof node.value.value === 'string') {
              checkClassNameValue(node.value, node.value.value)
            }

            if (
              node.value.type === 'JSXExpressionContainer' &&
              node.value.expression.type === 'TemplateLiteral'
            ) {
              node.value.expression.quasis.forEach((q) => {
                checkClassNameValue(q, q.value.raw)
              })
            }
          },
        }
      },
    },
    'no-hardcoded-dir': {
      meta: {
        type: 'problem',
        docs: {
          description: 'Disallow hardcoded dir values except approved ltr field containers',
        },
        schema: [],
      },
      create(context) {
        const allowedLtrElements = new Set([
          'Input',
          'Textarea',
          'TableCell',
          'p',
          'input',
          'textarea',
        ])

        const getElementName = (attributeNode) => {
          const openingElement = attributeNode.parent
          if (!openingElement || openingElement.type !== 'JSXOpeningElement') {
            return null
          }

          const nameNode = openingElement.name
          if (nameNode.type === 'JSXIdentifier') {
            return nameNode.name
          }

          return null
        }

        return {
          JSXAttribute(node) {
            if (node.name?.name !== 'dir' || !node.value || node.value.type !== 'Literal') {
              return
            }

            if (node.value.value !== 'rtl' && node.value.value !== 'ltr') {
              return
            }

            if (node.value.value === 'rtl') {
              context.report({
                node,
                message:
                  'Do not hardcode dir="rtl". Use document direction or i18n direction helpers instead.',
              })
              return
            }

            const elementName = getElementName(node)
            if (!elementName || !allowedLtrElements.has(elementName)) {
              context.report({
                node,
                message:
                  'dir="ltr" is only allowed on approved data fields (Input/Textarea/TableCell/p).',
              })
            }
          },
        }
      },
    },
  },
}

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      js.configs.recommended,
      tseslint.configs.recommended,
      reactHooks.configs.flat.recommended,
      reactRefresh.configs.vite,
    ],
    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
    },
    plugins: {
      'rtl-guard': rtlGuardPlugin,
    },
    rules: {
      'rtl-guard/no-physical-direction-classes': 'error',
      'rtl-guard/no-hardcoded-dir': 'error',
    },
  },
])
