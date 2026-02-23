const fs = require('fs')
const path = require('path')

const ROOT = path.resolve(__dirname, '..', 'src')
const PAGE_ROOT = path.join(ROOT, 'pages')

const FILE_EXTENSIONS = new Set(['.ts', '.tsx', '.css'])
const PAGE_EXTENSIONS = new Set(['.tsx'])

const physicalClassPattern = /\b(?:ml-|mr-|pl-|pr-|text-left\b|text-right\b|float-left\b|float-right\b)/
const hardcodedRtlPattern = /dir\s*=\s*"rtl"/

const violations = []

function walk(dir, acceptedExtensions, results = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true })

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name)
    if (entry.isDirectory()) {
      walk(fullPath, acceptedExtensions, results)
      continue
    }

    const ext = path.extname(entry.name)
    if (acceptedExtensions.has(ext)) {
      results.push(fullPath)
    }
  }

  return results
}

function toRelative(filePath) {
  return path.relative(path.resolve(__dirname, '..'), filePath).replace(/\\/g, '/')
}

function addViolation(filePath, lineNumber, message) {
  violations.push(`${toRelative(filePath)}:${lineNumber} ${message}`)
}

function lineNumberFromIndex(text, index) {
  return text.slice(0, index).split(/\r?\n/).length
}

function checkPhysicalClasses(filePath, text) {
  const lines = text.split(/\r?\n/)
  lines.forEach((line, index) => {
    if (physicalClassPattern.test(line)) {
      addViolation(
        filePath,
        index + 1,
        'Avoid physical direction classes. Use ms/me/ps/pe/text-start/text-end.'
      )
    }
  })
}

function checkHardcodedRtl(filePath, text) {
  if (!/\.(ts|tsx)$/.test(filePath)) {
    return
  }

  const lines = text.split(/\r?\n/)
  lines.forEach((line, index) => {
    if (hardcodedRtlPattern.test(line)) {
      addViolation(filePath, index + 1, 'Do not hardcode dir="rtl".')
    }
  })
}

function checkNonResponsiveGrids(filePath, text) {
  const classPattern = /className\s*=\s*"([^"]*\bgrid\b[^"]*)"/g
  let match = null

  while ((match = classPattern.exec(text)) !== null) {
    const classValue = match[1]

    const hasMultiCol = /\bgrid-cols-(2|3|4)\b/.test(classValue)
    if (!hasMultiCol) {
      continue
    }

    const hasResponsiveFallback = /(sm:|md:|lg:|xl:).*grid-cols-|grid-cols-1/.test(classValue)
    if (hasResponsiveFallback) {
      continue
    }

    const line = lineNumberFromIndex(text, match.index)
    addViolation(filePath, line, 'Multi-column grid without responsive fallback (use grid-cols-1 + breakpoint cols).')
  }
}

const sourceFiles = walk(ROOT, FILE_EXTENSIONS)
for (const file of sourceFiles) {
  const text = fs.readFileSync(file, 'utf8')
  checkPhysicalClasses(file, text)
  checkHardcodedRtl(file, text)
}

const pageFiles = walk(PAGE_ROOT, PAGE_EXTENSIONS)
for (const file of pageFiles) {
  const text = fs.readFileSync(file, 'utf8')
  checkNonResponsiveGrids(file, text)
}

if (violations.length > 0) {
  console.error('RTL/Responsive guard failed:')
  for (const violation of violations) {
    console.error(`- ${violation}`)
  }
  process.exit(1)
}

console.log('RTL/Responsive guard passed.')
