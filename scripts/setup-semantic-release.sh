#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Setting up Semantic Release for Video2PPT${NC}"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    echo "Please install Node.js first: https://nodejs.org/"
    exit 1
fi

echo -e "${GREEN}✅ Node.js $(node --version) found${NC}"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ npm $(npm --version) found${NC}"
echo ""

# Install dependencies
echo -e "${YELLOW}📦 Installing npm dependencies...${NC}"
npm install

echo ""
echo -e "${YELLOW}🔧 Setting up Husky hooks...${NC}"

# Initialize husky
npx husky install

# Add commit-msg hook for commitlint
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit ${1}'

# Add pre-commit hook for basic checks
cat > .husky/pre-commit << 'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Run basic checks before commit
echo "🔍 Running pre-commit checks..."

# Check for large files
find . -type f -size +10M | grep -v ".git" | while read file; do
    echo "⚠️  Warning: Large file detected: $file"
done

# Validate workflow files if changed
if git diff --cached --name-only | grep -q ".github/workflows/"; then
    echo "📋 Validating GitHub Actions workflows..."
    if [ -f "./scripts/validate-workflows.sh" ]; then
        ./scripts/validate-workflows.sh
    fi
fi

echo "✅ Pre-commit checks passed"
EOF

chmod +x .husky/pre-commit

echo -e "${GREEN}✅ Husky hooks configured${NC}"
echo ""

# Create example commit script
cat > scripts/commit-example.sh << 'EOF'
#!/bin/bash

# Example commit messages that follow Conventional Commits

echo "📝 Conventional Commit Examples:"
echo ""
echo "Features:"
echo "  git commit -m 'feat: add re-convert button for quick iterations'"
echo "  git commit -m 'feat(ui): implement gradient backgrounds'"
echo ""
echo "Bug Fixes:"
echo "  git commit -m 'fix: correct timestamp calculation error'"
echo "  git commit -m 'fix(finder): resolve extension registration issue'"
echo ""
echo "Documentation:"
echo "  git commit -m 'docs: update README with installation guide'"
echo "  git commit -m 'docs(api): add API documentation'"
echo ""
echo "Performance:"
echo "  git commit -m 'perf: optimize frame extraction algorithm'"
echo ""
echo "Breaking Changes:"
echo "  git commit -m 'feat!: change default output format to PNG'"
echo "  git commit -m 'feat: new API' -m 'BREAKING CHANGE: removed old endpoint'"
echo ""
echo "Other Types:"
echo "  style: code formatting"
echo "  refactor: code restructuring"
echo "  test: add tests"
echo "  build: build system changes"
echo "  ci: CI/CD changes"
echo "  chore: maintenance tasks"
echo ""
echo "💡 Use 'npm run commit' for interactive commit message creation"
EOF

chmod +x scripts/commit-example.sh

echo -e "${BLUE}📋 Summary${NC}"
echo "================================"
echo ""
echo -e "${GREEN}✅ Semantic Release configured successfully!${NC}"
echo ""
echo "🎯 Next Steps:"
echo ""
echo "1. Make commits using Conventional Commits format:"
echo "   ${YELLOW}git commit -m 'feat: add new feature'${NC}"
echo "   ${YELLOW}git commit -m 'fix: resolve bug'${NC}"
echo ""
echo "2. Or use interactive commit helper:"
echo "   ${YELLOW}npm run commit${NC}"
echo ""
echo "3. Test semantic release (dry run):"
echo "   ${YELLOW}npm run release:dry${NC}"
echo ""
echo "4. View commit examples:"
echo "   ${YELLOW}./scripts/commit-example.sh${NC}"
echo ""
echo "5. The release will automatically happen when you push to main/master"
echo ""
echo "📚 Documentation:"
echo "  - Conventional Commits: https://www.conventionalcommits.org/"
echo "  - Semantic Release: https://semantic-release.gitbook.io/"
echo ""
echo -e "${GREEN}🎉 Ready to use automated releases!${NC}"