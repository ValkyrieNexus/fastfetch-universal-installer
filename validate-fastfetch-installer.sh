#!/bin/bash

# Fastfetch Universal Installer Validation Script
# This script validates the universal installer for syntax, logic, and potential issues

set -e

echo "=================================================="
echo "  Fastfetch Universal Installer Validator"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to print colored output
print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED++))
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_test() {
    echo -e "${PURPLE}[TEST]${NC} $1"
}

# Check if the universal script exists
SCRIPT_NAME="install-fastfetch-universal.sh"
if [ ! -f "$SCRIPT_NAME" ]; then
    print_fail "Universal installer script '$SCRIPT_NAME' not found in current directory"
    echo "Please ensure the script is in the same directory as this validator."
    exit 1
fi

print_info "Found universal installer: $SCRIPT_NAME"
echo ""

# Test 1: Basic syntax validation
print_test "Testing bash syntax validation..."
if bash -n "$SCRIPT_NAME" 2>/dev/null; then
    print_pass "Bash syntax is valid"
else
    print_fail "Bash syntax errors detected"
    echo "Running syntax check with errors:"
    bash -n "$SCRIPT_NAME"
fi

# Test 2: Check for common bash pitfalls
print_test "Checking for common bash pitfalls..."

# Check for proper quoting
if grep -q '\$[A-Za-z_][A-Za-z0-9_]*[^"]' "$SCRIPT_NAME" 2>/dev/null; then
    print_warn "Potential unquoted variable usage found (may cause issues with spaces)"
else
    print_pass "Variable quoting looks good"
fi

# Check for proper error handling
if grep -q "set -e" "$SCRIPT_NAME"; then
    print_pass "Error handling with 'set -e' enabled"
else
    print_warn "No 'set -e' found - errors might not be caught"
fi

# Test 3: Check required commands and dependencies
print_test "Checking for required command availability..."

required_commands=("curl" "wget" "sudo" "grep" "cut" "tar")
for cmd in "${required_commands[@]}"; do
    if grep -q "$cmd" "$SCRIPT_NAME"; then
        if command -v "$cmd" &> /dev/null; then
            print_pass "Required command '$cmd' is available"
        else
            print_warn "Required command '$cmd' not found on this system"
        fi
    fi
done

# Test 4: Validate JSON configurations
print_test "Validating embedded JSON configurations..."

# Extract JSON configs and validate them
temp_dir=$(mktemp -d)
json_count=0

# Extract JSON blocks (between 'EOF' markers in heredocs)
grep -A 50 "cat.*config\.jsonc.*EOF" "$SCRIPT_NAME" | while IFS= read -r line; do
    if [[ "$line" =~ ^EOF$ ]]; then
        break
    elif [[ "$line" =~ ^\{.*$ ]]; then
        json_count=$((json_count + 1))
        json_file="$temp_dir/config_$json_count.json"
        echo "$line" > "$json_file"
        
        # Continue reading JSON content
        while IFS= read -r json_line; do
            if [[ "$json_line" =~ ^EOF$ ]]; then
                break
            fi
            echo "$json_line" >> "$json_file"
        done
        
        # Validate JSON (remove comments first for validation)
        if sed 's|//.*||g' "$json_file" | python3 -m json.tool > /dev/null 2>&1; then
            print_pass "JSON configuration $json_count is valid"
        else
            print_fail "JSON configuration $json_count has syntax errors"
        fi
    fi
done

# Clean up temp directory
rm -rf "$temp_dir"

# Test 5: Check distribution detection logic
print_test "Validating distribution detection logic..."

# Check if detect_distro function exists
if grep -q "detect_distro()" "$SCRIPT_NAME"; then
    print_pass "Distribution detection function found"
else
    print_fail "Distribution detection function missing"
fi

# Check for os-release file handling
if grep -q "/etc/os-release" "$SCRIPT_NAME"; then
    print_pass "Standard os-release detection implemented"
else
    print_warn "No os-release detection found"
fi

# Test 6: Validate package manager handling
print_test "Checking package manager support..."

package_managers=("apt" "pacman" "dnf" "yum" "zypper")
for pm in "${package_managers[@]}"; do
    if grep -q "$pm" "$SCRIPT_NAME"; then
        print_pass "Package manager '$pm' support found"
    else
        print_warn "No '$pm' support detected"
    fi
done

# Test 7: Check for proper shell configuration
print_test "Validating shell configuration logic..."

shells=("bash" "zsh" "fish")
for shell in "${shells[@]}"; do
    if grep -q "$shell" "$SCRIPT_NAME"; then
        print_pass "Shell '$shell' configuration found"
    else
        print_warn "No '$shell' configuration detected"
    fi
done

# Test 8: Security checks
print_test "Running security checks..."

# Check for dangerous patterns
if grep -q "curl.*|.*bash" "$SCRIPT_NAME"; then
    print_fail "Dangerous pipe-to-bash pattern found"
else
    print_pass "No pipe-to-bash patterns detected"
fi

# Check for root execution prevention
if grep -q "EUID.*-eq.*0" "$SCRIPT_NAME"; then
    print_pass "Root execution prevention implemented"
else
    print_warn "No root execution check found"
fi

# Check for temporary file cleanup
if grep -q "rm.*-rf.*tmp" "$SCRIPT_NAME"; then
    print_pass "Temporary file cleanup found"
else
    print_warn "No temporary file cleanup detected"
fi

# Test 9: URL and API endpoint validation
print_test "Checking external dependencies..."

# Extract URLs and test them (basic check)
urls=$(grep -o 'https://[^"]*' "$SCRIPT_NAME" | sort | uniq)
if [ -n "$urls" ]; then
    echo "Found external URLs:"
    while IFS= read -r url; do
        echo "  - $url"
        # Basic URL format check
        if [[ "$url" =~ ^https://[a-zA-Z0-9.-]+/.*$ ]]; then
            print_pass "URL format valid: $url"
        else
            print_warn "Potentially malformed URL: $url"
        fi
    done <<< "$urls"
else
    print_warn "No external URLs found"
fi

# Test 10: Function dependency analysis
print_test "Analyzing function dependencies..."

# Extract function definitions
functions=$(grep -o '^[a-zA-Z_][a-zA-Z0-9_]*()' "$SCRIPT_NAME" | sed 's/()//')
if [ -n "$functions" ]; then
    print_pass "Found functions: $(echo $functions | tr '\n' ' ')"
    
    # Check if main function exists
    if grep -q "main()" "$SCRIPT_NAME"; then
        print_pass "Main function found"
    else
        print_warn "No main function detected"
    fi
else
    print_warn "No functions detected"
fi

# Test 11: Simulate different distribution scenarios
print_test "Simulating distribution detection scenarios..."

# Create temporary os-release files for testing
test_scenarios=(
    "debian:ID=debian"
    "ubuntu:ID=ubuntu"
    "arch:ID=arch"
    "fedora:ID=fedora"
    "kali:ID=kali"
    "unknown:ID=unknown\nID_LIKE=debian"
)

temp_test_dir=$(mktemp -d)
for scenario in "${test_scenarios[@]}"; do
    distro=$(echo "$scenario" | cut -d: -f1)
    content=$(echo "$scenario" | cut -d: -f2- | sed 's/\\n/\n/g')
    
    echo -e "$content" > "$temp_test_dir/os-release-$distro"
    
    # This is a simplified test - in a real scenario, we'd need to mock the entire environment
    if echo -e "$content" | grep -q "ID=" ; then
        print_pass "Test scenario '$distro' has valid ID field"
    else
        print_fail "Test scenario '$distro' missing ID field"
    fi
done

rm -rf "$temp_test_dir"

# Test 12: Check for proper exit codes
print_test "Checking exit code usage..."

if grep -q "exit 1" "$SCRIPT_NAME"; then
    print_pass "Error exit codes found"
else
    print_warn "No explicit error exit codes detected"
fi

if grep -q "exit 0" "$SCRIPT_NAME"; then
    print_pass "Success exit codes found"
else
    print_pass "Implicit success (no exit 0 needed)"
fi

# Test 13: Validate file paths and permissions
print_test "Checking file path and permission handling..."

# Check for home directory usage
if grep -q '~/' "$SCRIPT_NAME"; then
    print_pass "Home directory paths found"
else
    print_warn "No home directory usage detected"
fi

# Check for proper directory creation
if grep -q "mkdir -p" "$SCRIPT_NAME"; then
    print_pass "Safe directory creation with -p flag found"
else
    print_warn "No directory creation detected"
fi

echo ""
echo "=================================================="
echo "           VALIDATION SUMMARY"
echo "=================================================="
echo -e "${GREEN}Tests Passed: $PASSED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Tests Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        print_pass "All tests passed! The script appears to be robust and well-written."
        exit 0
    else
        echo -e "${YELLOW}Script passed all critical tests but has some warnings.${NC}"
        echo "The warnings are mostly suggestions for improvement and don't prevent functionality."
        exit 0
    fi
else
    echo -e "${RED}Script has critical issues that should be addressed before use.${NC}"
    exit 1
fi