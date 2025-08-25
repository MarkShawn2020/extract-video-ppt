#!/bin/bash

# Validate GitHub Actions workflow files
# This script checks for common issues in workflow files

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Validating GitHub Actions Workflows${NC}"
echo ""

WORKFLOW_DIR=".github/workflows"
ERRORS=0
WARNINGS=0

# Check if workflow directory exists
if [ ! -d "$WORKFLOW_DIR" ]; then
    echo -e "${RED}❌ Workflow directory not found: $WORKFLOW_DIR${NC}"
    exit 1
fi

# Function to check workflow file
check_workflow() {
    local file=$1
    local filename=$(basename "$file")
    
    echo -e "${YELLOW}Checking: $filename${NC}"
    
    # Check if file exists and is readable
    if [ ! -r "$file" ]; then
        echo -e "${RED}  ❌ Cannot read file${NC}"
        ((ERRORS++))
        return
    fi
    
    # Check for basic YAML syntax (simple check)
    if ! python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
        echo -e "${RED}  ❌ Invalid YAML syntax${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}  ✅ Valid YAML syntax${NC}"
    fi
    
    # Check for common GitHub Actions issues
    
    # 1. Check for secrets in job-level if conditions
    if grep -q 'if:.*secrets\.' "$file"; then
        if grep -q 'if:.*secrets\.' "$file" | grep -v '^\s*#'; then
            echo -e "${RED}  ❌ Error: secrets context used in job-level if condition (not allowed)${NC}"
            echo "    Line: $(grep -n 'if:.*secrets\.' "$file" | head -1 | cut -d: -f1)"
            ((ERRORS++))
        fi
    fi
    
    # 2. Check for required keys
    if ! grep -q '^name:' "$file"; then
        echo -e "${YELLOW}  ⚠️  Warning: No workflow name defined${NC}"
        ((WARNINGS++))
    fi
    
    if ! grep -q '^on:' "$file"; then
        echo -e "${RED}  ❌ Error: No trigger (on:) defined${NC}"
        ((ERRORS++))
    fi
    
    if ! grep -q '^jobs:' "$file"; then
        echo -e "${RED}  ❌ Error: No jobs defined${NC}"
        ((ERRORS++))
    fi
    
    # 3. Check for deprecated actions
    if grep -q 'actions/checkout@v[12]' "$file"; then
        echo -e "${YELLOW}  ⚠️  Warning: Using old version of actions/checkout (recommend @v4)${NC}"
        ((WARNINGS++))
    fi
    
    if grep -q 'actions/setup-python@v[12]' "$file"; then
        echo -e "${YELLOW}  ⚠️  Warning: Using old version of actions/setup-python (recommend @v5)${NC}"
        ((WARNINGS++))
    fi
    
    # 4. Check for hardcoded values that should be variables
    if grep -q 'github.repository_owner == ' "$file"; then
        owner=$(grep 'github.repository_owner == ' "$file" | sed -n "s/.*== *['\"]\\([^'\"]*\\)['\"].*/\\1/p" | head -1)
        echo -e "${BLUE}  ℹ️  Info: Workflow is restricted to owner: $owner${NC}"
    fi
    
    # 5. Check for workflow_dispatch
    if grep -q 'workflow_dispatch:' "$file"; then
        echo -e "${GREEN}  ✅ Manual trigger enabled${NC}"
    fi
    
    # 6. Check permissions
    if grep -q 'permissions:' "$file"; then
        echo -e "${GREEN}  ✅ Permissions explicitly defined${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Warning: No explicit permissions defined${NC}"
        ((WARNINGS++))
    fi
    
    echo ""
}

# Check all workflow files
for workflow in "$WORKFLOW_DIR"/*.yml "$WORKFLOW_DIR"/*.yaml; do
    if [ -f "$workflow" ]; then
        check_workflow "$workflow"
    fi
done

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary:${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ No errors found${NC}"
else
    echo -e "${RED}❌ Found $ERRORS error(s)${NC}"
fi

if [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ No warnings${NC}"
else
    echo -e "${YELLOW}⚠️  Found $WARNINGS warning(s)${NC}"
fi

# Additional checks using actionlint if available
if command -v actionlint &> /dev/null; then
    echo ""
    echo -e "${BLUE}Running actionlint for detailed analysis...${NC}"
    actionlint || true
else
    echo ""
    echo -e "${YELLOW}💡 Tip: Install actionlint for more thorough validation:${NC}"
    echo "   brew install actionlint"
fi

# Exit with error if any errors found
if [ $ERRORS -gt 0 ]; then
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Workflow validation complete!${NC}"