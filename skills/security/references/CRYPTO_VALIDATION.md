# Cryptographic Failures & Input Validation
> Sections 5-6 of AI Code Security Anti-Patterns (Breadth)

## 5. Cryptographic Failures

**CWE References:** CWE-327 (Use of Broken or Risky Cryptographic Algorithm), CWE-328 (Reversible One-Way Hash), CWE-330 (Use of Insufficiently Random Values), CWE-326 (Inadequate Encryption Strength), CWE-759 (Use of One-Way Hash without a Salt)
**Severity:** High to Critical | **Related:** [[Cryptographic-Misuse]]

> **Risk:** AI models frequently suggest outdated or weak cryptographic algorithms (MD5, SHA-1, DES) learned from decades of legacy code in training data. Cryptographic failures lead to data exposure, password compromise, and authentication bypass. A 14% failure rate for CWE-327 was documented in AI-generated code, with "significant increase" in encryption vulnerabilities when using AI assistants.

### 5.1 Using Deprecated Algorithms (MD5, SHA1 for Security, DES)

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: Deprecated hash algorithms for security
// ========================================
FUNCTION hash_password_weak(password):
    // Vulnerable: MD5 is cryptographically broken
    RETURN md5(password)
END FUNCTION

FUNCTION verify_integrity_weak(data):
    // Vulnerable: SHA-1 has known collision attacks
    RETURN sha1(data)
END FUNCTION

FUNCTION encrypt_data_weak(plaintext, key):
    // Vulnerable: DES uses 56-bit keys (trivially breakable)
    cipher = DES.new(key, mode=ECB)
    RETURN cipher.encrypt(plaintext)
END FUNCTION

// Problems:
// - MD5: Collisions found in seconds, rainbow tables widely available
// - SHA-1: Collision attacks demonstrated (SHAttered, 2017)
// - DES: Brute-forceable in hours with modern hardware

// ========================================
// GOOD: Modern cryptographic algorithms
// ========================================
FUNCTION hash_password_secure(password):
    // Use bcrypt, Argon2, or scrypt for passwords
    salt = bcrypt.generate_salt(rounds=12)
    RETURN bcrypt.hash(password, salt)
END FUNCTION

FUNCTION verify_integrity_secure(data):
    // Use SHA-256, SHA-3, or BLAKE2 for integrity
    RETURN sha256(data)
END FUNCTION

FUNCTION encrypt_data_secure(plaintext, key):
    // Use AES-256-GCM or ChaCha20-Poly1305
    nonce = crypto.secure_random_bytes(12)
    cipher = AES_GCM.new(key, nonce)
    ciphertext, tag = cipher.encrypt_and_digest(plaintext)
    RETURN nonce + tag + ciphertext  // Include nonce and auth tag
END FUNCTION

// Algorithm selection guide:
// - Password hashing: bcrypt, Argon2id, scrypt (NOT SHA-256 alone)
// - Symmetric encryption: AES-256-GCM, ChaCha20-Poly1305
// - Integrity/checksums: SHA-256, SHA-3, BLAKE2
// - Signatures: Ed25519, ECDSA with P-256, RSA-2048+
```

### 5.2 Hardcoded Encryption Keys

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: Hardcoded encryption keys in source
// ========================================
CONSTANT ENCRYPTION_KEY = "MySecretKey12345"  // Committed to repo!
CONSTANT AES_KEY = bytes([0x2b, 0x7e, 0x15, 0x16, ...])  // Still hardcoded

FUNCTION encrypt_user_data(data):
    cipher = AES.new(ENCRYPTION_KEY, mode=GCM)
    RETURN cipher.encrypt(data)
END FUNCTION

// Problems:
// - Keys in version control are exposed forever
// - Cannot rotate keys without code changes
// - All environments share same key

// ========================================
// GOOD: External key management
// ========================================
FUNCTION get_encryption_key():
    // Option 1: Environment variable
    key = environment.get("ENCRYPTION_KEY")

    IF key IS NULL:
        THROW Error("ENCRYPTION_KEY environment variable required")
    END IF

    // Validate key length for AES-256
    key_bytes = base64_decode(key)
    IF key_bytes.length != 32:
        THROW Error("ENCRYPTION_KEY must be 256 bits")
    END IF

    RETURN key_bytes
END FUNCTION

FUNCTION encrypt_user_data(data):
    key = get_encryption_key()
    nonce = crypto.secure_random_bytes(12)
    cipher = AES_GCM.new(key, nonce)
    ciphertext, tag = cipher.encrypt_and_digest(data)
    RETURN nonce + tag + ciphertext
END FUNCTION

// Better: Use a secret manager for production
FUNCTION get_encryption_key_from_manager():
    TRY:
        // AWS Secrets Manager, HashiCorp Vault, Azure Key Vault, etc.
        secret = secret_manager.get_secret("encryption-key")
        RETURN base64_decode(secret.value)
    CATCH Error as e:
        log.error("Failed to retrieve encryption key", {error: e.message})
        THROW Error("Encryption key unavailable")
    END TRY
END FUNCTION
```

### 5.3 ECB Mode Usage

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: ECB mode reveals patterns in data
// ========================================
FUNCTION encrypt_ecb(plaintext, key):
    // Vulnerable: ECB encrypts identical blocks identically
    cipher = AES.new(key, mode=ECB)
    RETURN cipher.encrypt(pad(plaintext))
END FUNCTION

// Problem demonstration:
// Encrypting an image with ECB mode preserves visual patterns
// because identical 16-byte blocks produce identical ciphertext
// This reveals structure of the original data!

// Identical plaintexts produce identical ciphertexts:
// plaintext_block_1 = "AAAAAAAAAAAAAAAA"
// plaintext_block_2 = "AAAAAAAAAAAAAAAA"
// ciphertext_1 == ciphertext_2  // Information leaked!

// ========================================
// GOOD: Use authenticated encryption modes
// ========================================
FUNCTION encrypt_gcm(plaintext, key):
    // GCM mode: Each encryption is unique even for same plaintext
    nonce = crypto.secure_random_bytes(12)  // 96-bit nonce for GCM

    cipher = AES_GCM.new(key, nonce)
    ciphertext, auth_tag = cipher.encrypt_and_digest(plaintext)

    // Return nonce + tag + ciphertext (all needed for decryption)
    RETURN nonce + auth_tag + ciphertext
END FUNCTION

FUNCTION decrypt_gcm(encrypted_data, key):
    // Extract components
    nonce = encrypted_data[0:12]
    auth_tag = encrypted_data[12:28]
    ciphertext = encrypted_data[28:]

    cipher = AES_GCM.new(key, nonce)

    TRY:
        plaintext = cipher.decrypt_and_verify(ciphertext, auth_tag)
        RETURN plaintext
    CATCH AuthenticationError:
        // Tampering detected!
        log.warning("Decryption failed: authentication tag mismatch")
        THROW Error("Data integrity check failed")
    END TRY
END FUNCTION

// Alternative: CBC mode (if GCM not available)
FUNCTION encrypt_cbc(plaintext, key):
    // CBC requires random IV for each encryption
    iv = crypto.secure_random_bytes(16)

    cipher = AES_CBC.new(key, iv)
    padded = pkcs7_pad(plaintext, block_size=16)
    ciphertext = cipher.encrypt(padded)

    // Must also add HMAC for authentication (encrypt-then-MAC)
    mac = hmac_sha256(key, iv + ciphertext)

    RETURN iv + ciphertext + mac
END FUNCTION
```

### 5.4 Missing or Weak IVs/Nonces

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: Predictable or reused IVs/nonces
// ========================================
FUNCTION encrypt_static_iv(plaintext, key):
    // Vulnerable: Static IV - identical plaintexts have identical ciphertexts
    iv = bytes([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    cipher = AES_CBC.new(key, iv)
    RETURN cipher.encrypt(pad(plaintext))
END FUNCTION

FUNCTION encrypt_counter_nonce(plaintext, key, message_counter):
    // Vulnerable: Predictable counter-based nonce
    nonce = int_to_bytes(message_counter, length=12)
    cipher = AES_GCM.new(key, nonce)
    RETURN cipher.encrypt(plaintext)
END FUNCTION

FUNCTION encrypt_truncated_nonce(plaintext, key):
    // Vulnerable: Nonce too short
    nonce = crypto.secure_random_bytes(4)  // Only 32 bits!
    cipher = AES_GCM.new(key, nonce)
    RETURN cipher.encrypt(plaintext)
END FUNCTION

// Problems:
// - Static IV: Same plaintext → same ciphertext (pattern leakage)
// - Predictable nonce: Allows chosen-plaintext attacks
// - Short nonce: Birthday collision after ~2^16 messages
// - GCM with repeated nonce: CATASTROPHIC - authentication key recovered!

// ========================================
// GOOD: Cryptographically random IVs/nonces
// ========================================
FUNCTION encrypt_with_random_iv(plaintext, key):
    // Generate random IV for each encryption
    iv = crypto.secure_random_bytes(16)  // 128 bits for AES-CBC

    cipher = AES_CBC.new(key, iv)
    padded = pkcs7_pad(plaintext, block_size=16)
    ciphertext = cipher.encrypt(padded)

    // Prepend IV (it's not secret, just must be unique)
    RETURN iv + ciphertext
END FUNCTION

FUNCTION encrypt_with_random_nonce(plaintext, key):
    // Generate random nonce for each encryption
    nonce = crypto.secure_random_bytes(12)  // 96 bits for AES-GCM

    cipher = AES_GCM.new(key, nonce)
    ciphertext, tag = cipher.encrypt_and_digest(plaintext)

    RETURN nonce + tag + ciphertext
END FUNCTION

// For high-volume encryption: Use key+nonce management
FUNCTION encrypt_with_derived_nonce(plaintext, key, message_id):
    // Derive unique nonce from random key-specific prefix + message ID
    // This prevents nonce reuse across different encryption contexts

    nonce_key = derive_key(key, "nonce-derivation")
    nonce = hmac_sha256(nonce_key, message_id)[0:12]

    cipher = AES_GCM.new(key, nonce)
    ciphertext, tag = cipher.encrypt_and_digest(plaintext)

    RETURN message_id + tag + ciphertext  // Include message_id for decryption
END FUNCTION
```

### 5.5 Rolling Your Own Crypto

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: Custom cryptographic implementations
// ========================================
FUNCTION my_encrypt(plaintext, key):
    // Vulnerable: XOR "encryption" is trivially broken
    result = ""
    FOR i = 0 TO plaintext.length - 1:
        result += char(plaintext[i] XOR key[i % key.length])
    END FOR
    RETURN result
END FUNCTION

FUNCTION my_hash(data):
    // Vulnerable: Custom hash is not collision-resistant
    result = 0
    FOR byte IN data:
        result = (result * 31 + byte) % 2147483647
    END FOR
    RETURN result
END FUNCTION

FUNCTION my_random(seed):
    // Vulnerable: Linear congruential generator
    RETURN (seed * 1103515245 + 12345) % (2^31)
END FUNCTION

// Problems:
// - XOR cipher: Trivially broken with known-plaintext
// - Custom hash: Collisions easily found
// - LCG random: Completely predictable sequence

// ========================================
// GOOD: Use established cryptographic libraries
// ========================================
FUNCTION encrypt_properly(plaintext, key):
    // Use vetted library implementations
    // Python: cryptography library
    // Node.js: crypto module
    // Java: javax.crypto
    // Go: crypto/* packages

    // AES-GCM from standard library
    nonce = crypto.secure_random_bytes(12)
    cipher = crypto.createCipheriv("aes-256-gcm", key, nonce)

    ciphertext = cipher.update(plaintext) + cipher.final()
    auth_tag = cipher.getAuthTag()

    RETURN nonce + auth_tag + ciphertext
END FUNCTION

FUNCTION hash_properly(data):
    // Use standard library hash functions
    RETURN crypto.sha256(data)
END FUNCTION

FUNCTION random_properly(num_bytes):
    // Use OS-provided cryptographic randomness
    RETURN crypto.secure_random_bytes(num_bytes)
END FUNCTION

// Rule: Never implement cryptographic primitives yourself
// - Encryption: Use library AES-GCM, ChaCha20-Poly1305
// - Hashing: Use library SHA-256, SHA-3, BLAKE2
// - Signatures: Use library Ed25519, ECDSA
// - Random: Use library secrets module or os.urandom
```

### 5.6 Insecure Random Number Generation

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: Non-cryptographic RNG for security
// ========================================
FUNCTION generate_session_id_weak():
    // Vulnerable: Math.random() / random.random() is predictable
    RETURN random.randint(0, 999999999)
END FUNCTION

FUNCTION generate_token_weak():
    // Vulnerable: Using random module for security tokens
    chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    token = ""
    FOR i = 0 TO 32:
        token += chars[random.randint(0, chars.length - 1)]
    END FOR
    RETURN token
END FUNCTION

FUNCTION generate_key_weak():
    // Vulnerable: Time-based seeding
    random.seed(current_timestamp())
    key = random.randbytes(32)
    RETURN key
END FUNCTION

// Problems:
// - Math.random(): Uses predictable PRNG (Mersenne Twister)
// - Time seed: Attacker can guess seed from approximate time
// - Internal state: Can be recovered from ~624 outputs

// ========================================
// GOOD: Cryptographically secure randomness
// ========================================
FUNCTION generate_session_id_secure():
    // Use cryptographically secure random
    RETURN secrets.token_urlsafe(32)  // 256 bits of entropy
END FUNCTION

FUNCTION generate_token_secure():
    // Use secrets module (Python) or crypto.randomBytes (Node)
    RETURN secrets.token_hex(32)  // 256 bits as hex string
END FUNCTION

FUNCTION generate_key_secure():
    // Use OS entropy source
    RETURN os.urandom(32)  // 256 bits from /dev/urandom or equivalent
END FUNCTION

FUNCTION generate_password_secure(length):
    // Secure password generation
    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    password = ""
    FOR i = 0 TO length - 1:
        password += alphabet[secrets.randbelow(alphabet.length)]
    END FOR
    RETURN password
END FUNCTION

// Language-specific secure random:
// Python: secrets module, os.urandom
// Node.js: crypto.randomBytes, crypto.randomUUID
// Java: SecureRandom
// Go: crypto/rand
// Ruby: SecureRandom
// PHP: random_bytes, random_int
```

### 5.7 Improper Key Derivation

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: Weak key derivation methods
// ========================================
FUNCTION derive_key_weak(password):
    // Vulnerable: Direct hash of password
    RETURN sha256(password)
END FUNCTION

FUNCTION derive_key_truncated(password):
    // Vulnerable: Password truncation
    RETURN password.bytes()[0:32]  // Loses entropy!
END FUNCTION

FUNCTION derive_key_md5(password, salt):
    // Vulnerable: MD5 with low iteration count
    RETURN md5(salt + password)
END FUNCTION

FUNCTION derive_key_fast(password, salt):
    // Vulnerable: Single SHA iteration (too fast to brute-force resist)
    RETURN sha256(salt + password)
END FUNCTION

// Problems:
// - Direct hash: No salt, no iterations, vulnerable to rainbow tables
// - Truncation: Reduces entropy, predictable patterns
// - Fast hash: GPU can compute billions per second

// ========================================
// GOOD: Proper key derivation functions
// ========================================
FUNCTION derive_key_pbkdf2(password, salt):
    // PBKDF2 with high iteration count
    IF salt IS NULL:
        salt = crypto.secure_random_bytes(32)
    END IF

    key = pbkdf2_hmac(
        hash_name="sha256",
        password=password.encode(),
        salt=salt,
        iterations=600000,  // OWASP recommends 600,000+ for SHA-256
        key_length=32
    )
    RETURN {key: key, salt: salt}
END FUNCTION

FUNCTION derive_key_argon2(password, salt):
    // Argon2id - memory-hard, recommended for passwords
    IF salt IS NULL:
        salt = crypto.secure_random_bytes(16)
    END IF

    key = argon2id.hash(
        password=password,
        salt=salt,
        time_cost=3,         // Iterations
        memory_cost=65536,   // 64MB memory
        parallelism=4,       // 4 threads
        hash_len=32          // Output length
    )
    RETURN {key: key, salt: salt}
END FUNCTION

FUNCTION derive_key_scrypt(password, salt):
    // scrypt - memory-hard alternative
    IF salt IS NULL:
        salt = crypto.secure_random_bytes(32)
    END IF

    key = scrypt(
        password=password.encode(),
        salt=salt,
        n=2^17,       // CPU/memory cost (131072)
        r=8,          // Block size
        p=1,          // Parallelism
        key_length=32
    )
    RETURN {key: key, salt: salt}
END FUNCTION

// For deriving multiple keys from one password
FUNCTION derive_multiple_keys(password, salt):
    // Use HKDF to derive multiple keys from master key
    master_key = derive_key_argon2(password, salt).key

    encryption_key = hkdf_expand(
        master_key,
        info="encryption",
        length=32
    )

    mac_key = hkdf_expand(
        master_key,
        info="mac",
        length=32
    )

    RETURN {
        encryption_key: encryption_key,
        mac_key: mac_key
    }
END FUNCTION
```

---

## 6. Input Validation

**CWE References:** CWE-20 (Improper Input Validation), CWE-1284 (Improper Validation of Specified Quantity in Input), CWE-1333 (Inefficient Regular Expression Complexity), CWE-22 (Path Traversal), CWE-180 (Incorrect Behavior Order: Validate Before Canonicalize)
**Severity:** High | **Related:** [[Input-Validation]]

> **Risk:** Input validation failures are a foundational vulnerability enabling most other attack classes. AI-generated code frequently relies solely on client-side validation (trivially bypassed) or omits validation entirely. Missing length limits enable DoS attacks, improper type checking allows type confusion attacks, and ReDoS patterns can freeze services. All user input must be validated on the server with type, length, format, and range constraints.

### 6.1 Missing Server-Side Validation (Client-Only)

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: Client-side only validation
// ========================================
// Frontend JavaScript
FUNCTION validate_form_client_only():
    email = document.getElementById("email").value
    age = document.getElementById("age").value

    IF NOT email.includes("@"):
        show_error("Invalid email")
        RETURN FALSE
    END IF

    IF age < 0 OR age > 150:
        show_error("Invalid age")
        RETURN FALSE
    END IF

    // Form submits if client-side validation passes
    form.submit()
END FUNCTION

// Backend - NO validation!
FUNCTION create_user(request):
    // Vulnerable: Trusts client-side validation completely
    email = request.body.email
    age = request.body.age

    database.insert("users", {email: email, age: age})
    RETURN {success: TRUE}
END FUNCTION

// Attack: Attacker bypasses JavaScript with direct HTTP request
// curl -X POST /api/users -d '{"email":"not-an-email","age":-999}'
// Result: Invalid data stored in database

// ========================================
// GOOD: Server-side validation (client-side is UX only)
// ========================================
// Backend - validates everything
FUNCTION create_user(request):
    // Validate all input server-side
    validation_errors = []

    // Email validation
    email = request.body.email
    IF typeof(email) != "string":
        validation_errors.append("Email must be a string")
    ELSE IF NOT regex.match("^[^@]+@[^@]+\.[^@]+$", email):
        validation_errors.append("Invalid email format")
    ELSE IF email.length > 254:
        validation_errors.append("Email too long")
    END IF

    // Age validation
    age = request.body.age
    IF typeof(age) != "number" OR NOT is_integer(age):
        validation_errors.append("Age must be an integer")
    ELSE IF age < 0 OR age > 150:
        validation_errors.append("Age must be between 0 and 150")
    END IF

    IF validation_errors.length > 0:
        RETURN {success: FALSE, errors: validation_errors}
    END IF

    // Safe to process validated data
    database.insert("users", {email: email, age: age})
    RETURN {success: TRUE}
END FUNCTION

// Client-side validation is still useful for UX (immediate feedback)
// but NEVER rely on it for security
```

### 6.2 Improper Type Checking

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: Missing or weak type validation
// ========================================
FUNCTION process_payment_weak(request):
    amount = request.body.amount
    quantity = request.body.quantity

    // Vulnerable: No type checking
    total = amount * quantity

    // What if amount = "100" (string)? JavaScript: "100" * 2 = 200 (coerced)
    // What if amount = [100]? Some languages coerce arrays unexpectedly
    // What if quantity = {"$gt": 0}? NoSQL injection possible

    charge_card(user, total)
END FUNCTION

FUNCTION get_user_weak(request):
    user_id = request.params.id

    // Vulnerable: ID could be array, object, or unexpected type
    // MongoDB: ?id[$ne]=null returns all users!
    RETURN database.find_one({id: user_id})
END FUNCTION

FUNCTION calculate_discount_weak(price, discount_percent):
    // Vulnerable: No validation of numeric types
    // discount_percent = "50" → string concatenation in some languages
    // discount_percent = NaN → NaN propagates through calculations
    final_price = price - (price * discount_percent / 100)
    RETURN final_price
END FUNCTION

// ========================================
// GOOD: Strict type validation
// ========================================
FUNCTION process_payment_safe(request):
    // Validate amount
    amount = request.body.amount
    IF typeof(amount) != "number":
        THROW ValidationError("Amount must be a number")
    END IF
    IF NOT is_finite(amount) OR is_nan(amount):
        THROW ValidationError("Amount must be a valid number")
    END IF
    IF amount <= 0:
        THROW ValidationError("Amount must be positive")
    END IF

    // Validate quantity
    quantity = request.body.quantity
    IF typeof(quantity) != "number" OR NOT is_integer(quantity):
        THROW ValidationError("Quantity must be an integer")
    END IF
    IF quantity <= 0 OR quantity > 1000:
        THROW ValidationError("Quantity must be between 1 and 1000")
    END IF

    // Safe to calculate
    total = amount * quantity

    // Additional: Prevent floating point issues with currency
    total_cents = round(total * 100)  // Work in cents
    charge_card(user, total_cents)
END FUNCTION

FUNCTION get_user_safe(request):
    user_id = request.params.id

    // Strict type checking
    IF typeof(user_id) != "string":
        THROW ValidationError("User ID must be a string")
    END IF

    // Format validation (e.g., UUID)
    IF NOT is_valid_uuid(user_id):
        THROW ValidationError("Invalid user ID format")
    END IF

    RETURN database.find_one({id: user_id})
END FUNCTION

// Type coercion helper with explicit validation
FUNCTION parse_integer_strict(value, min, max):
    IF typeof(value) == "number":
        IF NOT is_integer(value):
            THROW ValidationError("Expected integer, got float")
        END IF
        result = value
    ELSE IF typeof(value) == "string":
        IF NOT regex.match("^-?[0-9]+$", value):
            THROW ValidationError("Invalid integer format")
        END IF
        result = parse_int(value)
    ELSE:
        THROW ValidationError("Expected number or numeric string")
    END IF

    IF result < min OR result > max:
        THROW ValidationError("Value out of range: " + min + " to " + max)
    END IF

    RETURN result
END FUNCTION
```

### 6.3 Missing Length Limits

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: No length limits on input
// ========================================
FUNCTION create_post_unlimited(request):
    title = request.body.title
    content = request.body.content

    // Vulnerable: No length limits
    // Attacker sends 1GB title, exhausts memory/storage
    database.insert("posts", {title: title, content: content})
END FUNCTION

FUNCTION search_unlimited(request):
    query = request.params.q

    // Vulnerable: Long query strings can DoS search systems
    // Also enables ReDoS if query is used in regex
    results = database.search(query)
    RETURN results
END FUNCTION

FUNCTION process_file_unlimited(request):
    file_content = request.body.file

    // Vulnerable: No file size limit
    // Attacker uploads 10GB file, exhausts disk/memory
    save_file(file_content)
END FUNCTION

// Real-world DoS: JSON payload with deeply nested objects
// {"a":{"a":{"a":{"a":...}}}}  // 1000 levels deep
// Can crash parsers or exhaust stack space

// ========================================
// GOOD: Enforce length limits on all inputs
// ========================================
CONSTANT MAX_TITLE_LENGTH = 200
CONSTANT MAX_CONTENT_LENGTH = 50000
CONSTANT MAX_SEARCH_QUERY = 500
CONSTANT MAX_FILE_SIZE = 10 * 1024 * 1024  // 10MB
CONSTANT MAX_JSON_DEPTH = 20

FUNCTION create_post_limited(request):
    title = request.body.title
    content = request.body.content

    // Validate title length
    IF typeof(title) != "string":
        THROW ValidationError("Title must be a string")
    END IF
    IF title.length == 0:
        THROW ValidationError("Title is required")
    END IF
    IF title.length > MAX_TITLE_LENGTH:
        THROW ValidationError("Title exceeds " + MAX_TITLE_LENGTH + " characters")
    END IF

    // Validate content length
    IF typeof(content) != "string":
        THROW ValidationError("Content must be a string")
    END IF
    IF content.length > MAX_CONTENT_LENGTH:
        THROW ValidationError("Content exceeds " + MAX_CONTENT_LENGTH + " characters")
    END IF

    database.insert("posts", {title: title, content: content})
END FUNCTION

FUNCTION search_limited(request):
    query = request.params.q

    IF typeof(query) != "string":
        THROW ValidationError("Query must be a string")
    END IF
    IF query.length > MAX_SEARCH_QUERY:
        THROW ValidationError("Search query too long")
    END IF
    IF query.length < 2:
        THROW ValidationError("Search query too short")
    END IF

    results = database.search(query)
    RETURN results
END FUNCTION

// Configure request body limits at framework level
FUNCTION configure_server():
    server.set_body_limit(MAX_FILE_SIZE)
    server.set_json_depth_limit(MAX_JSON_DEPTH)
    server.set_parameter_limit(1000)  // Max form fields
    server.set_header_size_limit(8192)  // 8KB header limit
END FUNCTION

// Array length limits
FUNCTION process_batch_request(request):
    items = request.body.items

    IF NOT is_array(items):
        THROW ValidationError("Items must be an array")
    END IF
    IF items.length > 100:
        THROW ValidationError("Maximum 100 items per batch")
    END IF

    FOR item IN items:
        process_single_item(item)
    END FOR
END FUNCTION
```

### 6.4 Regex Denial of Service (ReDoS)

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: Vulnerable regex patterns
// ========================================
FUNCTION validate_email_redos(email):
    // Vulnerable: Catastrophic backtracking on malformed input
    // Pattern with nested quantifiers
    pattern = "^([a-zA-Z0-9]+)+@[a-zA-Z0-9]+\.[a-zA-Z]+$"

    // Attack input: "aaaaaaaaaaaaaaaaaaaaaaaaaaaa!"
    // Regex engine tries exponential combinations before failing
    RETURN regex.match(pattern, email)
END FUNCTION

FUNCTION validate_url_redos(url):
    // Vulnerable: Multiple overlapping groups
    pattern = "^(https?://)?(www\.)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/.*)*$"

    // Attack input: "http://aaaaaaaaaaaaaaaaaaaaaaaa"
    RETURN regex.match(pattern, url)
END FUNCTION

FUNCTION search_with_regex(user_pattern, content):
    // Vulnerable: User-controlled regex pattern
    // Attacker provides: "(a+)+$" with input "aaaaaaaaaaaaaaaaaaaX"
    RETURN regex.search(user_pattern, content)
END FUNCTION

// ReDoS patterns to avoid:
// - Nested quantifiers: (a+)+, (a*)*
// - Overlapping alternatives: (a|a)+, (a|ab)+
// - Quantified groups with repetition: (a+b+)+

// ========================================
// GOOD: Safe regex patterns and practices
// ========================================
FUNCTION validate_email_safe(email):
    // First: Length check before regex
    IF email.length > 254:
        RETURN FALSE
    END IF

    // Use atomic groups or possessive quantifiers if available
    // Or use simpler, non-backtracking patterns
    pattern = "^[^@\s]+@[^@\s]+\.[^@\s]+$"  // Simple, no backtracking risk

    RETURN regex.match(pattern, email)
END FUNCTION

FUNCTION validate_email_best(email):
    // Best: Use a validated library
    TRY:
        validated = email_validator.validate(email)
        RETURN TRUE
    CATCH ValidationError:
        RETURN FALSE
    END TRY
END FUNCTION

FUNCTION validate_url_safe(url):
    // Length limit first
    IF url.length > 2048:
        RETURN FALSE
    END IF

    // Use URL parser instead of regex
    TRY:
        parsed = url_parser.parse(url)
        RETURN parsed.host IS NOT NULL AND parsed.protocol IN ["http:", "https:"]
    CATCH ParseError:
        RETURN FALSE
    END TRY
END FUNCTION

FUNCTION search_with_safe_pattern(user_input, content):
    // Never use user input directly as regex
    // Escape special characters if literal match needed
    escaped_input = regex.escape(user_input)

    // Set timeout on regex operations
    RETURN regex.search(escaped_input, content, timeout=1000)  // 1 second max
END FUNCTION

// Use RE2 or similar guaranteed-linear-time regex engine
FUNCTION search_with_re2(pattern, content):
    // RE2 rejects patterns that could cause exponential backtracking
    TRY:
        compiled = re2.compile(pattern)
        RETURN compiled.search(content)
    CATCH UnsupportedPatternError:
        // Pattern rejected due to backtracking risk
        THROW ValidationError("Invalid search pattern")
    END TRY
END FUNCTION

// Safe pattern testing
FUNCTION is_safe_regex(pattern):
    // Detect common ReDoS patterns
    dangerous_patterns = [
        "\\(.+\\)+\\+",    // (x+)+
        "\\(.+\\)\\*\\+",  // (x*)+
        "\\(.+\\)+\\*",    // (x+)*
        "\\(.+\\|.+\\)+"   // (a|b)+
    ]

    FOR dangerous IN dangerous_patterns:
        IF regex.search(dangerous, pattern):
            RETURN FALSE
        END IF
    END FOR

    RETURN TRUE
END FUNCTION
```

### 6.5 Accepting and Processing Untrusted Data

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: Trusting external data sources
// ========================================
FUNCTION process_webhook_unsafe(request):
    // Vulnerable: No signature verification
    data = json.parse(request.body)

    // Attacker can spoof webhook requests
    IF data.event == "payment_completed":
        mark_order_paid(data.order_id)  // Dangerous!
    END IF
END FUNCTION

FUNCTION fetch_and_process_unsafe(url):
    // Vulnerable: Processing arbitrary external content
    response = http.get(url)
    data = json.parse(response.body)

    // No validation of response structure
    database.insert("external_data", data)
END FUNCTION

FUNCTION deserialize_unsafe(serialized_data):
    // Vulnerable: Pickle/eval deserialization of untrusted data
    // Allows arbitrary code execution!
    object = pickle.loads(serialized_data)
    RETURN object
END FUNCTION

FUNCTION process_xml_unsafe(xml_string):
    // Vulnerable: XXE (XML External Entity) attack
    parser = xml.create_parser()
    doc = parser.parse(xml_string)
    // Attacker XML: <!ENTITY xxe SYSTEM "file:///etc/passwd">
    RETURN doc
END FUNCTION

// ========================================
// GOOD: Validate and sanitize external data
// ========================================
FUNCTION process_webhook_safe(request):
    // Verify webhook signature
    signature = request.headers.get("X-Signature")
    expected = hmac_sha256(WEBHOOK_SECRET, request.raw_body)

    IF NOT constant_time_compare(signature, expected):
        log.warning("Invalid webhook signature", {ip: request.ip})
        RETURN {status: 401, error: "Invalid signature"}
    END IF

    // Validate payload structure
    data = json.parse(request.body)

    IF NOT validate_webhook_schema(data):
        RETURN {status: 400, error: "Invalid payload"}
    END IF

    // Process verified and validated data
    IF data.event == "payment_completed":
        // Additional verification: Check with payment provider
        IF verify_payment_with_provider(data.payment_id):
            mark_order_paid(data.order_id)
        END IF
    END IF
END FUNCTION

FUNCTION fetch_and_process_safe(url):
    // Validate URL is from allowed sources
    parsed_url = url_parser.parse(url)
    IF parsed_url.host NOT IN ALLOWED_HOSTS:
        THROW ValidationError("URL host not allowed")
    END IF

    // Fetch with timeout and size limits
    response = http.get(url, timeout=10, max_size=1024*1024)

    // Parse and validate structure
    TRY:
        data = json.parse(response.body)
    CATCH JSONError:
        THROW ValidationError("Invalid JSON response")
    END TRY

    // Validate against expected schema
    validated_data = validate_schema(data, EXPECTED_SCHEMA)

    // Sanitize before storing
    sanitized = sanitize_object(validated_data)
    database.insert("external_data", sanitized)
END FUNCTION

FUNCTION deserialize_safe(data, format):
    // Never use pickle/eval for untrusted data
    // Use safe serialization formats
    IF format == "json":
        RETURN json.parse(data)
    ELSE IF format == "msgpack":
        RETURN msgpack.unpack(data)
    ELSE:
        THROW Error("Unsupported format")
    END IF
END FUNCTION

FUNCTION process_xml_safe(xml_string):
    // Disable external entities and DTDs
    parser = xml.create_parser(
        resolve_entities=FALSE,
        load_dtd=FALSE,
        no_network=TRUE
    )

    TRY:
        doc = parser.parse(xml_string)
        RETURN doc
    CATCH XMLError as e:
        log.warning("XML parsing failed", {error: e.message})
        THROW ValidationError("Invalid XML")
    END TRY
END FUNCTION

// Schema validation helper
FUNCTION validate_schema(data, schema):
    // Use JSON Schema or similar validation library
    validator = JsonSchemaValidator(schema)

    IF NOT validator.is_valid(data):
        errors = validator.get_errors()
        THROW ValidationError("Schema validation failed: " + errors.join(", "))
    END IF

    RETURN data
END FUNCTION
```

### 6.6 Missing Canonicalization

```
// PSEUDOCODE - Implement in your target language

// ========================================
// BAD: Validation without canonicalization
// ========================================
FUNCTION check_path_unsafe(requested_path):
    // Vulnerable: Path not canonicalized before validation
    IF requested_path.starts_with("/uploads/"):
        // Bypass: "../../../etc/passwd" doesn't start with /uploads/
        // But resolves to outside the directory!
        RETURN read_file(requested_path)
    END IF
    THROW AccessDenied("Invalid path")
END FUNCTION

FUNCTION check_url_unsafe(url):
    // Vulnerable: URL manipulation bypasses check
    // Blocked: "http://internal-server"
    // Bypass: "http://internal-server%00.example.com"
    // Bypass: "http://0x7f000001" (127.0.0.1 in hex)
    // Bypass: "http://localhost" vs "http://LOCALHOST" vs "http://127.0.0.1"

    IF url.contains("internal-server"):
        THROW AccessDenied("Internal URLs not allowed")
    END IF

    RETURN http.get(url)
END FUNCTION

FUNCTION validate_filename_unsafe(filename):
    // Vulnerable: Unicode normalization bypass
    // Blocked: "config.php"
    // Bypass: "config.php" with full-width characters (ｃｏｎｆｉｇ.php)
    // Bypass: "config.php\x00.txt" (null byte injection)

    IF filename.ends_with(".php"):
        THROW AccessDenied("PHP files not allowed")
    END IF

    save_file(filename)
END FUNCTION

FUNCTION check_html_unsafe(content):
    // Vulnerable: Case-sensitive blacklist
    // Blocked: "<script>"
    // Bypass: "<SCRIPT>", "<ScRiPt>", "<script ", etc.

    IF content.contains("<script>"):
        THROW AccessDenied("Scripts not allowed")
    END IF

    RETURN content
END FUNCTION

// ========================================
// GOOD: Canonicalize before validation
// ========================================
FUNCTION check_path_safe(requested_path):
    // Canonicalize path first
    base_path = path.resolve("/uploads")
    canonical_path = path.resolve(requested_path)

    // Verify canonical path is within allowed directory
    IF NOT canonical_path.starts_with(base_path):
        log.warning("Path traversal attempt", {
            requested: requested_path,
            resolved: canonical_path
        })
        THROW AccessDenied("Invalid path")
    END IF

    // Additional: Verify path doesn't contain null bytes
    IF requested_path.contains("\x00"):
        THROW AccessDenied("Invalid path characters")
    END IF

    RETURN read_file(canonical_path)
END FUNCTION

FUNCTION check_url_safe(url):
    // Parse and canonicalize URL
    TRY:
        parsed = url_parser.parse(url)
    CATCH ParseError:
        THROW AccessDenied("Invalid URL")
    END TRY

    // Normalize hostname
    host = parsed.hostname.lower()

    // Resolve to IP to catch obfuscation
    TRY:
        resolved_ip = dns.resolve(host)
    CATCH DNSError:
        THROW AccessDenied("Cannot resolve host")
    END TRY

    // Check against blocked IP ranges
    blocked_ranges = [
        "127.0.0.0/8",     // Localhost
        "10.0.0.0/8",      // Private
        "172.16.0.0/12",   // Private
        "192.168.0.0/16",  // Private
        "169.254.0.0/16"   // Link-local
    ]

    FOR range IN blocked_ranges:
        IF ip_in_range(resolved_ip, range):
            THROW AccessDenied("Internal addresses not allowed")
        END IF
    END FOR

    // Additional: Block by resolved hostname
    IF host IN BLOCKED_HOSTS:
        THROW AccessDenied("Host not allowed")
    END IF

    RETURN http.get(url)
END FUNCTION

FUNCTION validate_filename_safe(filename):
    // Remove null bytes
    clean_name = filename.replace("\x00", "")

    // Normalize Unicode (NFC form)
    normalized = unicode_normalize("NFC", clean_name)

    // Convert to ASCII-safe representation
    ascii_name = transliterate_to_ascii(normalized)

    // Extract actual extension (after normalization)
    extension = path.get_extension(ascii_name).lower()

    // Whitelist allowed extensions
    allowed_extensions = [".jpg", ".png", ".gif", ".pdf", ".txt"]
    IF extension NOT IN allowed_extensions:
        THROW AccessDenied("File type not allowed: " + extension)
    END IF

    // Generate safe filename
    safe_name = uuid() + extension
    save_file(safe_name)
END FUNCTION

FUNCTION sanitize_html_safe(content):
    // Case-insensitive checking
    lower_content = content.lower()

    // Better: Use HTML parser and whitelist approach
    parsed = html_parser.parse(content)

    // Remove all script elements regardless of case
    FOR element IN parsed.find_all("script"):
        element.remove()
    END FOR

    // Remove event handlers
    FOR element IN parsed.find_all():
        FOR attr IN element.attributes:
            IF attr.name.lower().starts_with("on"):
                element.remove_attribute(attr.name)
            END IF
        END FOR
    END FOR

    // Best: Use a sanitization library like DOMPurify
    RETURN DOMPurify.sanitize(content)
END FUNCTION

// Canonicalization order matters:
// 1. Decode (URL decode, Unicode normalize)
// 2. Canonicalize (resolve paths, lowercase hostnames)
// 3. Validate (check against rules)
// 4. Encode for output context (HTML encode, URL encode)
```

---

