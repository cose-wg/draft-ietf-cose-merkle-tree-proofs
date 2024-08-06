---
v: 3

title: COSE Receipts
docname: draft-ietf-cose-merkle-tree-proofs-latest
stand_alone: true
ipr: trust200902
area: Security
wg: COSE
kw: Internet-Draft
cat: std
submissiontype: IETF
pi:
  toc: yes
  sortrefs: yes
  symrefs: yes

author:
- ins: O. Steele
  name: Orie Steele
  organization: Transmute
  email: orie@transmute.industries
  country: United States
- ins: H. Birkholz
  name: Henk Birkholz
  org: Fraunhofer SIT
  abbrev: Fraunhofer SIT
  email: henk.birkholz@sit.fraunhofer.de
  street: Rheinstrasse 75
  code: '64295'
  city: Darmstadt
  country: Germany
- ins: A. Delignat-Lavaud
  name: Antoine Delignat-Lavaud
  organization: Microsoft
  email: antdl@microsoft.com
  country: UK
- ins: C. Fournet
  name: Cedric Fournet
  organization: Microsoft
  email: fournet@microsoft.com
  country: UK

normative:
  RFC7049: CBOR
  RFC9053: COSE
  RFC9162: certificate-transparency-v2

informative:
  RFC7120:
  RFC9052:
  RFC8610:
  RFC8949:
  RFC8126: iana-considerations-guide
  BCP205: RFC7942
  RFC8392: CWT
  I-D.draft-ietf-cbor-edn-literals: cbor-edn-literals
  I-D.ietf-cose-cwt-claims-in-headers: cwt-header-claims
  I-D.ietf-cose-typ-header-parameter: cose-typ


--- abstract

COSE (CBOR Object Signing and Encryption) Receipts prove properties of a verifiable data structure to a verifier.
Verifiable data structures and associated proof types enable security properties, such as minimal disclosure, transparency and non-equivocation.
Transparency helps maintain trust over time, and has been applied to certificates, end to end encrypted messaging systems, and supply chain security.
This specification enables concise transparency oriented systems, by building on CBOR (Concise Binary Object Representation) and COSE.
The extensibility of the approach is demonstrated by providing CBOR encodings for RFC9162.

--- middle

# Introduction

Merkle trees are one of many verifiable data structures that enable tamper evident secure information storage, through their ability to protect the integrity of batches of documents or collections of statements.
Merkle trees can be constructed from simple operations such as concatenation and digest via a cryptographic hash function, however, more advanced constructions enable proofs of different properties of the underlying verifiable data structure.
Verifiable data structure proofs can be used to prove a document is in a database (proof of inclusion), that a database is append only (proof of consistency), that a smaller set of statements are contained in a large set of statements (proof of disclosure, a special case of proof of inclusion), or proof that certain data is not yet present in a database (proofs of non inclusion).
Differences in the representation of verifiable data structures, and verifiable data structure proof types, can increase the burden for implementers, and create interoperability challenges for transparency services.
This document describes how to convey verifiable data structures, and associated proof types in COSE envelopes.
For conciseness, a COSE object securing a verifiable data structure and its associated proofs, is referred to as a COSE Receipt.

## Requirements Notation

{::boilerplate bcp14-tagged}

# CBOR Tags

Editorial Note (To be removed by RFC Editor).

This section will be removed before the document is completed, its purpose is to track the TBD code points references throughout the draft.

395 is TBD_1:

: A requested cose header parameter representing the verifiable data structure used.

396 is TBD_2:

: A requested cose header parameter representing the verifiable data structure parameters map (proofs map).

The other codepoints are assigned from the registries established in this draft, they are therefore not marked TBD.

# Terminology

CDDL:
: Concise Data Definition Language (CDDL) is defined in {{RFC8610}}.

EDN:
: CBOR Extended Diagnostic Notation (EDN) is defined in {{RFC8949}}, where it is referred to as "diagnostic notation", and is revised in {{-cbor-edn-literals}}.

Verifiable Data Structure (VDS):

: A data structure which supports one or more Proof Types.
  This property is conceptually similar to "alg" (1), it described an algorithm used to maintain the verifiable data structure, for example a binary merkle tree algorithm.


Verifiable Data Structure Parameters (VDP):

: Parameters to a verifiable data structure that are used to prove properties, such as authentication, inclusion, consistency, and freshness.
  Parameters can include multiple proofs of a given type, or multiple types of proof (inclusion and consistency).
  This property is conceptually similar to COSE Header Parameter "epk" (-1) or CBOR Web Token (CWT) claim "cnf" (8), it is applied to a verifiable data structure, to confirm a property.
  For example an encrypted message might be decrypted using epk and a private key, a digital signature for authentication might be verified using cnf and the (CWT) claim "nonce" and "audience", and an inclusion proof for a binary merkle tree might be verified with VDP and some entry that is being tested or inclusion in the tree.

Proof Type:

: A verifiable process, that proves properties of a Verifiable Data Structure.
  For example, a VDS, such as a binary merkle tree, can support multiple proofs of type "inclusion" where each proof confirms that a given entry is included in a merkle root.

Proof Value:

: An encoding of a Proof Type in CBOR.

Entry:

: An entry in a verifiable data structure for which proofs can be derived.

Receipt:

: A COSE object, as defined in {{RFC9052}}, containing the header parameters necessary to convey VDP for an associated VDS.


# Verifiable Data Structures in CBOR {#sec-generic-verifiable-data-structures}

This section describes representations of verifiable data structure proofs in CBOR.
For example, construction of a merkle tree leaf, or an inclusion proof from a leaf to a merkle root, might have several different representations, depending on the verifiable data structure used.
Differences in representations are necessary to support efficient verification, unique security or privacy properties, and for compatibility with specific implementations.
This document defines two extension points for enabling verifiable data structures with COSE and provides concrete examples for the structures and proofs defined in {{-certificate-transparency-v2}}.
The design of these structures is influenced by the conventions established for COSE Keys.

During testing and development the experimental range SHOULD be used, unless early assignment for a provisional entry has been completed.

## Structures {#sec-cose-verifiable-data-structures}

Similar to [COSE Key Types](https://www.iana.org/assignments/cose/cose.xhtml#key-type), different verifiable data structures support different algorithms.
As EC2 keys (1: 2) support both digital signature and key agreement algorithms, RFC9162_SHA256 (TBD_1 : 1) supports both inclusion and consistency proofs.

This document establishes a registry of verifiable data structure algorithms, with the following initial contents:

| Name            | Value | Description                      | Reference
|---
| N/A             | 0     | N/A                              | N/A
| RFC9162_SHA256  | 1     | SHA256 Binary Merkle Tree        | {{-certificate-transparency-v2}}
| EXPERIMENTAL    | 11    | Unknown                          | RFC XXXX
| EXPERIMENTAL    | 22    | Unknown                          | RFC XXXX
| EXPERIMENTAL    | 33    | Unknown                          | RFC XXXX
{: #cose-verifiable-data-structures align="left" title="COSE Verifiable Data Structures"}

When designing new verifiable data structures, please request the next available positive integer as your requested assignment, for example:

| Name            | Value | Description                      | Reference
|---
| N/A             | 0     | N/A                              | N/A
| RFC9162_SHA256  | 1     | SHA256 Binary Merkle Tree        | {{-certificate-transparency-v2}}
| Your name       | TBD (requested assignment 2) | tbd       | Your specification
{: #cose-verifiable-data-structures-registration-guidance align="left" title="How to register new structures"}

## Parameters {#sec-cose-verifiable-data-structure-parameters}

Similar to [COSE Key Type Parameters](https://www.iana.org/assignments/cose/cose.xhtml#key-type-parameters), as EC2 keys (1: 2) keys require and give meaning to specific parameters, such as -1 (crv), -2 (x), -3 (y), -4 (d), RFC9162_SHA256 (TBD_1 : 1) supports both (-1) inclusion and (-2) consistency proofs.

This document establishes a registry of verifiable data structure algorithms, with the following initial contents:

| Verifiable Data Structure | Name               | Label | CBOR Type        | Description                   | Reference
|---
| 1                         | inclusion proofs   | -1    | array (of bstr)  | Proof of inclusion            | {{sec-rfc9162-sha256-inclusion-proof}}
| 1                         | consistency proofs | -2    | array (of bstr)  | Proof of append only property | {{sec-rfc9162-sha256-consistency-proof}}
| 11                        | unknown            | -1    | array (of bstr)  | Unknown                       | RFC XXXX
| 22                        | unknown            | -1    | array (of bstr)  | Unknown                       | RFC XXXX
| 33                        | unknown            | -1    | array (of bstr)  | Unknown                       | RFC XXXX
{: #cose-verifiable-data-structures-parameters align="left" title="COSE Verifiable Data Structure Parameters"}

Proof types are specific to their associated "verifiable data structure", for example, different Merkle trees might support different representations of "inclusion proof" or "consistency proof".
Implementers should not expect interoperability across "verifiable data structures", but they should expect conceptually similar properties across the different registered proof types.
For example, 2 different merkle tree based verifiable data structures might both support proofs of inclusion.
Protocols requiring proof of inclusion ought to be able to preserve their functionality, while switching from one verifiable data structure to another, so long as both structures support the same proof types.
Security analysis SHOULD be conducted prior to migrating to new structures to ensure the new security and privacy assumptions are acceptable for the use case.
When designing new verifiable data structure parameters (or proof types), please start with -1, and count down for each proof type supported by your verifiable data structure:

| Verifiable Data Structure | Name               | Label | CBOR Type        | Description                   | Reference
|---
| 1                           | inclusion proofs   | -1    | array (of bstr)  | Proof of inclusion            | {{sec-rfc9162-sha256-inclusion-proof}}
| 1                           | consistency proofs | -2    | array (of bstr)  | Proof of append only property | {{sec-rfc9162-sha256-consistency-proof}}
|TBD (requested assignment 2) | new proof type     | -1    | tbd              | tbd                           | Your_Specification
|TBD (requested assignment 2) | new proof type     | -2    | tbd              | tbd                           | Your_Specification
|TBD (requested assignment 2) | new proof type     | -3    | tbd              | tbd                           | Your_Specification
{: #cose-verifiable-data-structures-parameters-registration-guidance align="left" title="How to register new parameters"}

## Usage

This document registered a new COSE Header Parameter `receipts` (394) to enable this Receipts to be conveyed in the protected and unprotected headers of COSE Objects.

When the receipts parameter is present, the associated verifiable data structure and verifiable data structure proofs MUST match entries present in the registries established in RFC XXXX.

The following informative CDDL is provided:

~~~ cddl
Receipt = #6.18(COSE_Sign1)

Protected_Header = {
  * cose-label => cose-value
}

Unprotected_Header = {
  &(receipts: 394)  => [+ Receipt]
  * cose-label => cose-value
}

COSE_Sign1 = [
  protected   : bstr .cbor Protected_Header,
  unprotected : Unprotected_Header,
  payload     : bstr / nil,
  signature   : bstr
]
~~~
{: #fig-receipts-cddl title="CDDL for a COSE Sign1 with attached receipts"}

The following informative EDN is provided:

~~~ cbor-diag
18(                                 / COSE Sign 1                   /
    [
      h'a4012603...6d706c65',       / Protected                     /
      {                             / Unprotected                   /
        394: [                      / Receipts (2)                  /
          h'd284586c...4191f9d2'    / Receipt 1                     /
          h'c624586c...8f4af97e'    / Receipt 2                     /
        ]
      },
      nil,                          / Detached payload              /
      h'79ada558...3a28bae4'        / Signature                     /
    ]
)
~~~
{: #fig-receipts-edn title="EDN for a COSE Sign1 with attached receipts"}

### Registration Requirements

Each specification MUST define how to encode the verifiable data structure and its parameters (also called proof types) in CBOR.
Each specification MUST define how to produce and consume the supported proof types.
See {{sec-rfc-9162-verifiable-data-structure-definition}} as an example.

# RFC9162_SHA256 {#sec-rfc-9162-verifiable-data-structure-definition}

This section defines how the data structures described in {{-certificate-transparency-v2}} are mapped to the terminology defined in this document, using CBOR and COSE.

## Verifiable Data Structure

The integer identifier for this Verifiable Data Structure is 1.
The string identifier for this Verifiable Data Structure is "RFC9162_SHA256".
See {{cose-verifiable-data-structures}}.
See {{-certificate-transparency-v2}}, 2.1.1. Definition of the Merkle Tree, for a complete description of this verifiable data structure.

## Inclusion Proof {#sec-rfc9162-sha256-inclusion-proof}

See {{-certificate-transparency-v2}}, 2.1.3.1. Generating an Inclusion Proof, for a complete description of this verifiable data structure proof type.

The CBOR representation of an inclusion proof for RFC9162_SHA256 is:

~~~~ cddl
inclusion-proof = bstr .cbor [

    ; tree size at current merkle root
    tree-size: int

    ; index of leaf in tree
    leaf-index: int

    ; path from leaf to current merkle root
    inclusion-path: [ + bstr ]
]
~~~~
{: #rfc9162-sha256-cbor-inclusion-proof align="left" title="CBOR Encoded RFC9162 Inclusion Proof"}

### Receipt of Inclusion

In a signed inclusion proof, the previous merkle tree root, maps to tree-size-1, and is a detached payload.
In general, all specifications are encouraged to make proof payloads detached in this way where possible.
Profiles of proof signatures are encouraged to make additional protected header parameters mandatory, to ensure that claims are processed with their intended semantics.
One way to include this information in the COSE structure is use of the typ (type) Header Parameter, see {{-cose-typ}} and the similar guidance provided in {{-cwt-header-claims}}.
The protected header for an RFC9162_SHA256 inclusion proof signature is:

~~~~ cddl
protected-header-map = {
  &(alg: 1) => int
  &(vds: 395) => int
  * cose-label => cose-value
}
~~~~
{: #vds-in-inclusion-receipt-protected-header align="left" title="Protected Header for a Receipt of Inclusion"}

* alg (label: 1): REQUIRED. Signature algorithm identifier. Value type: int.
* vds (label: 395): REQUIRED. verifiable data structure algorithm identifier. Value type: int.

The unprotected header for an RFC9162_SHA256 inclusion proof signature is:

~~~~ cddl

inclusion-proofs = [ + inclusion-proof ]

verifiable-proofs = {
  &(inclusion-proof: -1) => inclusion-proofs
}

unprotected-header-map = {
  &(vdp: 396) => verifiable-proofs
  * cose-label => cose-value
}
~~~~
{: #vdp-in-unprotected-header align="left" title="A Verifiable Data Structure Proofs in an Unprotected Header"}

* vdp (label: 396): REQUIRED. Verifiable data structure proofs. Value type: Map.
* inclusion-proof (label: -1): REQUIRED. Inclusion proofs. Value type: Array of bstr.

The payload of an RFC9162_SHA256 inclusion proof signature is the previous Merkle tree hash as defined in {{-certificate-transparency-v2}}.
The payload MUST be detached.
Detaching the payload forces verifiers to recompute the root from the inclusion proof signature, this protects against implementation errors where the signature is verified but the merkle root does not match the inclusion proof.
The EDN for a Receipt containing an inclusion proof for RFC9162_SHA256 is:

~~~~ cbor-diag
18(                                 / COSE Sign 1                   /
    [
      h'a4012604...6d706c65',       / Protected                     /
      {                             / Unprotected                   /
        396: {                      / Proofs                        /
          -1: [                     / Inclusion proofs (1)          /
            h'83080783...32568964', / Inclusion proof 1             /
          ]
        },
      },
      nil,                          / Detached payload              /
      h'2e34df43...8d74d55e'        / Signature                     /
    ]
)
~~~~
{: #rfc9162_sha256_inclusion_receipt align="left" title="Example inclusion receipt"}

The EDN for the Protected Header in the example above is:

~~~~ cbor-diag
{                                   / Protected                     /
  1: -7,                            / Algorithm                     /
  4: h'4930714e...7163316b',        / Key identifier                /
  395: 1,                           / Verifiable Data Structure     /
}
~~~~
{: #rfc9162_sha256_inclusion_receipt_header align="left" title="Example inclusion receipt decoded protected header"}

The VDS in the protected header is necessary to understand the VDP in the unprotected header.

The EDN for the inclusion proof in the Unprotected Header is:

~~~~ cbor-diag
[                                   / Inclusion proof 1             /
  8,                                / Tree size                     /
  7,                                / Leaf index                    /
  [                                 / Inclusion hashes (3)          /
     h'2a8d7dfc...15d10b22'         / Intermediate hash 1           /
     h'75f177fd...2e73a8ab'         / Intermediate hash 2           /
     h'0bdaaed3...32568964'         / Intermediate hash 3           /
  ]
]
~~~~
{: #rfc9162_sha256_inclusion_receipt_inclusion_proof align="left" title="Example inclusion receipt decoded inclusion proof"}

The VDS in the protected header is necessary to understand the inclusion proof structure in the unprotected header.

The inclusion proof and signature are verified in order.
First the verifiers applies the inclusion proof to a possible entry (set member) bytes.
If this process fails, the inclusion proof may have been tampered with.
If this process succeeds, the result is a merkle root, which in the attached as the COSE Sign1 payload.
Second the verifier checks the signature of the COSE Sign1.
If the resulting signature verifies, the Receipt has proved inclusion of the entry in the verifiable data structure.
If the resulting signature does not verify, the signature may have been tampered with.
It is recommended that implementations return a single boolean result for Receipt verification operations, to reduce the chance of accepting a valid signature over an invalid inclusion proof.

## Consistency Proof {#sec-rfc9162-sha256-consistency-proof}

See {{-certificate-transparency-v2}}, 2.1.4.1. Generating a Consistency Proof, for a complete description of this verifiable data structure proof type.

The cbor representation of a consistency proof for RFC9162_SHA256 is:

~~~~ cddl
consistency-proof =  bstr .cbor [

    ; previous merkle root tree size
    tree-size-1: int

    ; latest merkle root tree size
    tree-size-2: int

    ; path from previous merkle root to latest merkle root.
    consistency-path: [ + bstr ]

]
~~~~
{: #rfc9162_sha256_consistency_proof align="left" title="CBOR Encoded RFC9162 Consistency Proof"}

Editors note: tree-size-1, could be omitted, if an inclusion-proof is always present, since the inclusion proof contains, tree-size-1.

### Receipt of Consistency

In a signed consistency proof, the latest merkle tree root, maps to tree-size-2, and is an attached payload.

The protected header for an RFC9162_SHA256 consistency proof signature is:

~~~~ cddl
protected-header-map = {
  &(alg: 1) => int
  &(vds: 395) => int
  * cose-label => cose-value
}
~~~~
{: #vds-in-consistency-receipt-protected-header align="left" title="Protected Header for a Receipt of Consistency"}

* alg (label: 1): REQUIRED. Signature algorithm identifier. Value type: int.
* vds (label: TBD_1): REQUIRED. Verifiable data structure algorithm identifier. Value type: int.

The unprotected header for an RFC9162_SHA256 consistency proof signature is:

~~~~ cddl

consistency-proofs = [ + consistency-proof ]

verifiable-proofs = {
  &(consistency-proof: -2) => consistency-proofs
}

unprotected-header-map = {
  &(vdp: 396) => verifiable-proofs
  * cose-label => cose-value
}
~~~~

* vdp (label: 396): REQUIRED. Verifiable data structure proofs. Value type: Map.
* consistency-proof (label: -2): REQUIRED. Consistency proofs. Value type: Array of bstr.

The payload of an RFC9162_SHA256 consistency proof signature is:
The latest Merkle tree hash as defined in {{-certificate-transparency-v2}}.
The payload MUST be attached.

The EDN for a Receipt containing a consistency proof for RFC9162_SHA256 is:

~~~~ cbor-diag
18(                                 / COSE Sign 1                   /
    [
      h'a3012604...392b6601',       / Protected                     /
      {                             / Unprotected                   /
        396: {                      / Proofs                        /
          -2: [                     / Consistency proofs (1)        /
            h'83040682...2e73a8ab', / Consistency proof 1           /
          ]
        },
      },
      h'430b6fd7...f74c7fc4',       / Payload (Attached)            /
      h'd97befea...f30631cb'        / Signature                     /
    ]
)
~~~~
{: #rfc9162_sha256_consistency_receipt align="left" title="Example consistency receipt"}

The VDS in the protected header is necessary to understand the VDP in the unprotected header.

The EDN for the Protected Header in the example above is:

~~~~ cbor-diag
{                                   / Protected                     /
  1: -7,                            / Algorithm                     /
  4: h'68747470...6d706c65',        / Key identifier                /
  395: 1,                           / Verifiable Data Structure     /
}
~~~~
{: #rfc9162_sha256_consistency_receipt_header align="left" title="Example consistency receipt decoded protected header"}

The EDN for the consistency proof in the Unprotected Header is:

~~~~ cbor-diag
[                                   / Consistency proof 1           /
  4,                                / Tree size 1                   /
  6,                                / Tree size 2                   /
  [                                 / Consistency hashes (2)        /
     h'0bdaaed3...32568964'         / Intermediate hash 1           /
     h'75f177fd...2e73a8ab'         / Intermediate hash 2           /
  ]
]
~~~~
{: #rfc9162_sha256_consistency_receipt_consistency_proof align="left" title="Example consistency receipt decoded consistency proof"}

The VDS in the protected header is necessary to understand the consistency proof structure in the unprotected header.

The signature and consistency proof are verified in order.

First the verifier checks the signature on the COSE Sign1.
If the verification fails, the consistency proof is not checked.
Second the consistency proof is checked by applying a previous inclusion proof, to the consistency proof.
If the verification fails, the append only property of the verifiable data structure is not assured.
This approach is specific to RFC9162_SHA256, different verifiable data structures may not support consistency proofs.
It is recommended that implementations return a single boolean result for Receipt verification operations, to reduce the chance of accepting a valid signature over an invalid consistency proof.

# Privacy Considerations

See the privacy considerations section of:

- {{-certificate-transparency-v2}}
- {{-COSE}}

## Log Length

Some structures and proofs leak the size of the log at the time of inclusion.
In the case that a log only stores certain kinds of information, this can reveal details that could impact reputation.
For example, if a transparency log only stored breach notices, a receipt for a breach notice would reveal the number of previous breaches at the time the notice was made transparent.

## Header Parameters

Additional header parameters can reveal information about the transparency service or its log entries.
A privacy analysis MUST be performed for all mandatory fields in profiles based on this specification.

# Security Considerations

See the security considerations section of:

- {{-certificate-transparency-v2}}
- {{-COSE}}

## Choice of Signature Algorithms

A security analysis MUST be performed to ensure that the digital signature algorithm `alg` has the appropriate strength to secure receipts.

It is recommended to select signature algorithms that share cryptographic components with the verifiable data structure used, for example:
Both RFC9162_SHA256 and ES256 depend on the sha-256 hash function.

## Validity Period

In some cases, receipts MAY include strict validity periods, for example, activation not too far in the future, or expiration, not too far in the past.
See the `iat`, `nbf`, and `exp` claims in {{-CWT}}, for one way to accomplish this.
The details of expressing validity periods are out of scope for this document.

## Status Updates

In some cases, receipts should be "revocable" or "suspendible", after being issued, regardless of their validity period.
The details of expressing statuses are out of scope for this document.

# Acknowledgements {#Acknowledgements}

We would like to thank
Maik Riechert,
Jon Geater,
Mike Jones,
Mike Prorock,
Ilari Liusvaara,
for their contributions (some of which substantial) to this draft and to the initial set of implementations.

# IANA Considerations

## Additions to Existing Registries

### New Entries to the COSE Header Parameters Registry

This document requests IANA to add new values to the 'COSE Algorithms' and to the 'COSE Header Algorithm Parameters' registries in the 'Standards Action With Expert Review' category.

#### COSE Header Algorithm Parameters

##### Receipts

* Name: receipts
* Label: TBD_0 (requested assignment 394)
* Value type: array (of bstr)
* Value registry: https://www.iana.org/assignments/cose/cose.xhtml#header-parameters
* Description: Priority ordered list of CBOR encoded Receipts.
* Reference: RFC XXXX

##### Verifiable Data Structure

* Name: vds
* Label: TBD_1 (requested assignment 395)
* Value type: int
* Value registry: https://www.iana.org/assignments/cose/cose.xhtml#header-parameters
* Description: Algorithm name for verifiable data structure, used to produce verifiable data structure proofs.
* Reference: RFC XXXX

##### Verifiable Data Structure Proofs

* Name: vdp (requested assignment 396)
* Label: TBD_2
* Value type: map
* Value registry: https://www.iana.org/assignments/cose/cose.xhtml#header-parameters
* Description: Location for verifiable data structure proofs in COSE Header Parameters.
* Reference: RFC XXXX

### COSE Verifiable Data Structures {#verifiable-data-structure-registry}

IANA will be asked to establish a registry of verifiable data structure identifiers, named "COSE Verifiable Data Structures" to be administered under a Specification Required policy {{-iana-considerations-guide}}.

Template:

* Name: The name of the verifiable data structure
* Value: The identifier for the verifiable data structure
* Description: A brief description of the verifiable data structure
* Reference: Where the verifiable data structure is defined

Initial contents: Provided in {{cose-verifiable-data-structures}}

#### Expert Review

This IANA registries is established under a Specification Required policy.

This section gives some general guidelines for what the experts should be looking for, but they are being designated as experts for a reason, so they should be given substantial latitude.

Expert reviewers should take into consideration the following points:

*  Point squatting should be discouraged.
Reviewers are encouraged to get sufficient information for registration requests to ensure that the usage is not going to duplicate one that is already registered, and that the point is likely to be used in deployments.

* Specifications are required for all point assignments.
Early Allocation is permissible, see Section 2 of {{RFC7120}}.
Provisional assignments to expired drafts MUST be removed from the registry.

* Points assigned in this registry MUST have references that match the COSE Verifiable Data Structure Parameters registry.
It is not permissible to assign points in this registry, for which no Verifiable Data Structure Parameters entries exist.

### COSE Verifiable Data Structure Parameters {#verifiable-data-structure-parameters-registry}

IANA will be asked to establish a registry of verifiable data structure parameters, named "COSE Verifiable Data Structure Parameters" to be administered under a Specification Required policy {{-iana-considerations-guide}}.

Template:

* Verifiable Data Structure: The identifier for the verifiable data structure
* Name: The name of the proof type
* Label: The integer of the proof type
* CBOR Type: The cbor data type of the proof
* Description: The description of the proof type
* Reference: Where the proof type is defined

Initial contents: Provided in {{cose-verifiable-data-structures-parameters}}

#### Expert Review

This IANA registries is established under a Specification Required policy.

This section gives some general guidelines for what the experts should be looking for, but they are being designated as experts for a reason, so they should be given substantial latitude.

Expert reviewers should take into consideration the following points:

*  Point squatting should be discouraged.
Reviewers are encouraged to get sufficient information for registration requests to ensure that the usage is not going to duplicate one that is already registered, and that the point is likely to be used in deployments.

* Specifications are required for all point assignments.
Early Allocation is permissible, see Section 2 of {{RFC7120}}.
Provisional assignments to expired drafts MUST be removed from the registry.

* Points assigned in this registry MUST have references that match the COSE Verifiable Data Structures registry.
It is not permissible to assign points in this registry, for which no Verifiable Data Structure entry exists.

--- back

# Implementation Status

Note to RFC Editor: Please remove this section as well as references to {{BCP205}} before AUTH48.

This section records the status of known implementations of the protocol defined by this specification at the time of posting of this Internet-Draft, and is based on a proposal described in {{BCP205}}.
The description of implementations in this section is intended to assist the IETF in its decision processes in progressing drafts to RFCs.
Please note that the listing of any individual implementation here does not imply endorsement by the IETF.
Furthermore, no effort has been spent to verify the information presented here that was supplied by IETF contributors.
This is not intended as, and must not be construed to be, a catalog of available implementations or their features.
Readers are advised to note that other implementations may exist.

According to {{BCP205}}, "this will allow reviewers and working groups to assign due consideration to documents that have the benefit of running code, which may serve as evidence of valuable experimentation and feedback that have made the implemented protocols more mature.
It is up to the individual working groups to use this information as they see fit".

## Implementer

An open-source implementation was initiated and is maintained by the Transmute Industries Inc. - Transmute.

## Implementation Name

An application demonstrating the concepts is available at [COSE SCITT Receipts](https://github.com/transmute-industries/cose?tab=readme-ov-file#scitt-receipts)

## Implementation URL

An open-source implementation is available at:

- https://github.com/transmute-industries/cose

## Maturity

The code's level of maturity is considered to be "prototype".

## Coverage and Version Compatibility

The current version ('main') implements the verifiable data structure algorithm, inclusion proof and consistency proof concepts of this draft.

## License

The project and all corresponding code and data maintained on GitHub are provided under the Apache License, version 2.

## Implementation Dependencies

The implementation uses the Concise Binary Object Representation {{-CBOR}} (https://cbor.io/).

The implementation uses the CBOR Object Signing and Encryption {{-COSE}}, maintained at:
- https://github.com/erdtman/cose-js

The implementation uses an implementation of {{-certificate-transparency-v2}}, maintained at:

- https://github.com/transmute-industries/rfc9162/tree/main/src/CoMETRE

## Contact

Orie Steele (orie@transmute.industries)
