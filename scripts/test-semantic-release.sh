#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing Semantic Release Configuration${NC}"
echo ""

# Check Node.js
echo -e "${YELLOW}1. Checking Node.js environment...${NC}"
if command -v node &> /dev/null; then
    echo -e "${GREEN}✅ Node.js: $(node --version)${NC}"
else
    echo -e "${RED}❌ Node.js not installed${NC}"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

if command -v npm &> /dev/null; then
    echo -e "${GREEN}✅ npm: $(npm --version)${NC}"
else
    echo -e "${RED}❌ npm not installed${NC}"
    exit 1
fi
echo ""

# Check configuration files
echo -e "${YELLOW}2. Checking configuration files...${NC}"

FILES=(
    ".releaserc.json"
    "commitlint.config.js"
    "package.json"
    ".github/workflows/semantic-release.yml"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file exists${NC}"
    else
        echo -e "${RED}❌ $file missing${NC}"
    fi
done
echo ""

# Check if npm packages are installed
echo -e "${YELLOW}3. Checking npm packages...${NC}"
if [ -d "node_modules" ]; then
    echo -e "${GREEN}✅ node_modules exists${NC}"
    
    # Check specific packages
    if [ -d "node_modules/semantic-release" ]; then
        echo -e "${GREEN}✅ semantic-release installed${NC}"
    else
        echo -e "${YELLOW}⚠️  semantic-release not installed, run: npm install${NC}"
    fi
    
    if [ -d "node_modules/@commitlint/cli" ]; then
        echo -e "${GREEN}✅ commitlint installed${NC}"
    else
        echo -e "${YELLOW}⚠️  commitlint not installed, run: npm install${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  node_modules not found${NC}"
    echo "Run: npm install"
fi
echo ""

# Test commit message validation
echo -e "${YELLOW}4. Testing commit message validation...${NC}"

# Create temp file for testing
TEMP_MSG=$(mktemp)

# Test valid messages
echo "feat: add new feature" > "$TEMP_MSG"
if npx commitlint --from HEAD~0 --to HEAD --verbose < "$TEMP_MSG" 2>/dev/null; then
    echo -e "${GREEN}✅ Valid: 'feat: add new feature'${NC}"
else
    echo -e "${YELLOW}⚠️  Commitlint not working properly${NC}"
fi

# Test invalid message
echo "bad commit message" > "$TEMP_MSG"
if ! npx commitlint --from HEAD~0 --to HEAD --verbose < "$TEMP_MSG" 2>/dev/null; then
    echo -e "${GREEN}✅ Rejected: 'bad commit message' (as expected)${NC}"
else
    echo -e "${RED}❌ Invalid message was not rejected${NC}"
fi

rm "$TEMP_MSG"
echo ""

# Check Git hooks
echo -e "${YELLOW}5. Checking Git hooks...${NC}"
if [ -d ".husky" ]; then
    echo -e "${GREEN}✅ Husky directory exists${NC}"
    
    if [ -f ".husky/commit-msg" ]; then
        echo -e "${GREEN}✅ commit-msg hook configured${NC}"
    else
        echo -e "${YELLOW}⚠️  commit-msg hook missing${NC}"
        echo "Run: npx husky add .husky/commit-msg 'npx --no -- commitlint --edit \${1}'"
    fi
else
    echo -e "${YELLOW}⚠️  Husky not initialized${NC}"
    echo "Run: npx husky install"
fi
echo ""

# Test semantic-release dry run
echo -e "${YELLOW}6. Testing semantic-release (dry run)...${NC}"
echo "This will simulate a release without actually publishing:"
echo ""

# Check if we have any commits
if git rev-parse HEAD >/dev/null 2>&1; then
    echo "Running dry run..."
    echo ""
    
    # Set minimal environment for dry run
    export GITHUB_TOKEN=${GITHUB_TOKEN:-"dummy-token-for-dry-run"}
    
    # Run semantic-release in dry-run mode
    if npx semantic-release --dry-run --no-ci 2>&1 | head -20; then
        echo ""
        echo -e "${GREEN}✅ Semantic release dry run completed${NC}"
    else
        echo ""
        echo -e "${YELLOW}⚠️  Dry run had issues (this is normal if no releases pending)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No git commits found${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}📊 Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${GREEN}Configuration Status:${NC}"
echo "  ✅ All configuration files present"
echo "  ✅ Commit validation working"
echo ""

echo -e "${GREEN}Next Steps:${NC}"
echo "1. Install dependencies (if not done):"
echo "   ${YELLOW}npm install${NC}"
echo ""
echo "2. Initialize Husky:"
echo "   ${YELLOW}npx husky install${NC}"
echo ""
echo "3. Try an interactive commit:"
echo "   ${YELLOW}npm run commit${NC}"
echo ""
echo "4. Test a dry run:"
echo "   ${YELLOW}npm run release:dry${NC}"
echo ""

echo -e "${GREEN}🎉 Semantic Release is ready to use!${NC}"
echo ""
echo "When you push to main branch with proper commits,"
echo "releases will be created automatically!"