# GitHub Actions Workflow Fix

## ✅ Issue Resolved

### Problem
```yaml
# ❌ INCORRECT - This causes an error
if: |
  github.repository_owner == 'markshawn2020' &&
  secrets.APPLE_CERTIFICATE != ''
```

**Error Message:**
```
Invalid workflow file
Unrecognized named-value: 'secrets'. Located at position 47 within expression
```

### Root Cause
The `secrets` context is **not available** in job-level `if` conditions in GitHub Actions. This is a documented limitation.

### Solution Applied

#### Before (Incorrect):
```yaml
jobs:
  signed-release:
    runs-on: macos-latest
    if: |
      github.repository_owner == 'markshawn2020' &&
      secrets.APPLE_CERTIFICATE != ''  # ❌ This doesn't work
```

#### After (Correct):
```yaml
jobs:
  signed-release:
    runs-on: macos-latest
    if: github.repository_owner == 'markshawn2020'  # ✅ Simple condition
    
    steps:
      - name: Validate Secrets  # ✅ Check secrets in a step
        run: |
          if [[ -z "${{ secrets.APPLE_CERTIFICATE }}" ]]; then
            echo "::error::APPLE_CERTIFICATE secret is not configured."
            exit 1
          fi
```

## 📚 GitHub Actions Context Availability

| Context | Job Level `if` | Step Level `if` | Step `run` |
|---------|---------------|-----------------|------------|
| `github` | ✅ | ✅ | ✅ |
| `env` | ✅ | ✅ | ✅ |
| `vars` | ✅ | ✅ | ✅ |
| `secrets` | ❌ | ✅ | ✅ |
| `needs` | ✅ | ✅ | ✅ |
| `inputs` | ✅ | ✅ | ✅ |

## 🛠 Files Modified

1. **`.github/workflows/release-signed.yml`**
   - Removed `secrets` from job-level `if` condition
   - Added `Validate Secrets` step to check for required secrets
   - Fails fast with clear error messages if secrets are missing

2. **`scripts/validate-workflows.sh`** (New)
   - Validates all workflow files for common issues
   - Checks for the `secrets` in job-level `if` anti-pattern
   - Validates YAML syntax
   - Provides warnings for best practices

## 🎯 Best Practices

### ✅ DO: Check Secrets in Steps
```yaml
steps:
  - name: Check Secret
    if: ${{ secrets.MY_SECRET != '' }}  # Works in step condition
    run: echo "Secret exists"
    
  - name: Use Secret
    env:
      MY_VAR: ${{ secrets.MY_SECRET }}  # Works in step env
    run: echo "Using secret"
```

### ❌ DON'T: Use Secrets in Job Conditions
```yaml
jobs:
  my-job:
    if: ${{ secrets.MY_SECRET != '' }}  # Will fail!
    runs-on: ubuntu-latest
```

### Alternative Patterns

1. **Early Exit Pattern** (Recommended):
```yaml
steps:
  - name: Validate Requirements
    run: |
      if [[ -z "${{ secrets.REQUIRED_SECRET }}" ]]; then
        echo "::error::Missing required secret"
        exit 1
      fi
```

2. **Conditional Steps Pattern**:
```yaml
steps:
  - name: Step requiring secret
    if: ${{ secrets.MY_SECRET != '' }}
    run: echo "This only runs if secret exists"
```

3. **Environment Check Pattern**:
```yaml
steps:
  - name: Setup Environment
    id: setup
    run: |
      if [[ -n "${{ secrets.MY_SECRET }}" ]]; then
        echo "HAS_SECRET=true" >> $GITHUB_OUTPUT
      else
        echo "HAS_SECRET=false" >> $GITHUB_OUTPUT
      fi
      
  - name: Use Secret
    if: steps.setup.outputs.HAS_SECRET == 'true'
    run: echo "Secret is available"
```

## 🧪 Testing

### Validate Workflows Locally
```bash
# Run validation script
./scripts/validate-workflows.sh

# Expected output:
# ✅ No errors found
# ✅ Valid YAML syntax
```

### Test in GitHub
```bash
# Push to a test branch
git checkout -b test-workflow
git add .github/workflows/
git commit -m "fix: correct secrets usage in workflows"
git push origin test-workflow

# Check Actions tab - workflows should parse correctly
```

## 📖 References

- [GitHub Actions Contexts Documentation](https://docs.github.com/en/actions/learn-github-actions/contexts)
- [GitHub Actions Conditional Jobs](https://docs.github.com/en/actions/using-jobs/using-conditions-to-control-job-execution)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## 🎉 Result

The workflow files are now:
- ✅ Syntactically correct
- ✅ Following GitHub Actions best practices
- ✅ Providing clear error messages when secrets are missing
- ✅ Ready for use in production

The signed release workflow will now:
1. Check if it's the repository owner
2. Validate all required secrets are present
3. Fail fast with helpful error messages if configuration is incomplete
4. Proceed with signed build only when properly configured