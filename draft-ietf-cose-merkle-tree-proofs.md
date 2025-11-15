---
v: 3

title: COSE (CBOR Object Signing and Encryption) Receipts
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
  organization: Tradeverifyd
  email: orie@or13.io
  country: United States
- ins: H. Birkholz
  name: Henk Birkholz
  org: Fraunhofer SIT
  abbrev: Fraunhofer SIT
  email: henk.birkholz@ietf.contact
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

contributor:
  - ins: A. Chamayou
    name: Amaury Chamayou
    organization: Microsoft
    email: amaury.chamayou@microsoft.com
    country: United Kingdom
  - ins: S. Lasker
    name: Steve Lasker
    email: stevenlasker@hotmail.com
  - ins: R. A. Martin
    name: Robert Martin
    organization: MITRE Corporation
    email: ramartin@mitre.org
    country: United States
  - ins: M. Wiseman
    name: Monty Wiseman
    org:
    country: USA
    email: mwiseman32@acm.org
  - ins: R. Williams
    name: Roy Williams
    org:
    country: USA
    email: roywill@msn.com

normative:
  RFC8610: CDDL
  RFC8949: CBOR
  RFC9053: COSE
  RFC9162:
  RFC9597: cwt-header-claims
  RFC9596: cose-typ

informative:
  RFC7120:
  RFC9052:
  RFC8126: iana-considerations-guide
  BCP205: RFC7942
  RFC8392: CWT
  I-D.draft-ietf-cbor-edn-literals: cbor-edn-literals


entity:
  SELF: "RFCthis"

--- abstract

COSE (CBOR Object Signing and Encryption) Receipts prove properties of a verifiable data structure to a verifier.
Verifiable data structures and associated proof types enable security properties, such as minimal disclosure, transparency and non-equivocation.
Transparency helps maintain trust over time, and has been applied to certificates, end to end encrypted messaging systems, and supply chain security.
This specification enables concise transparency oriented systems, by building on CBOR (Concise Binary Object Representation) and COSE.
The extensibility of the approach is demonstrated by providing CBOR encodings for Merkle inclusion and consistency proofs.

--- middle

# Introduction

COSE Receipts are signed proofs that include metadata about certain states of a verifiable data structure (VDS) that are true when the COSE Receipt was issued.
COSE Receipts can include proofs that a document is in a database (proof of inclusion), that a database is append only (proof of consistency), that a smaller set of statements are contained in a large set of statements (proof of disclosure, a special case of proof of inclusion), or proof that certain data is not yet present in a database (proofs of non inclusion).
Different VDS can produce different verifiable data structure proofs (VDP).
The combination of representations of various VDS and VDP can significantly increase the burden for implementers and create interoperability challenges for transparency services.
This document describes how to convey VDS and associated VDP types in unified COSE envelopes.

## Requirements Notation

{::boilerplate bcp14-tagged}

# New COSE Header Parameters {#param-list}

This document defines three new COSE header parameters, which are introduced up-front in this Section and elaborated on later in this document.

TBD_0 (requested assignment 394):

: A COSE header parameter named `receipts` with a value type of array where the array contains one or more COSE Receipts as specified in this document.

TBD_1 (requested assignment 395):

: A COSE header parameter named `vds` (Verifiable Data Structure), which conveys the algorithm identifier for a verifiable data structure.
  Correspondingly, this document introduces a new registry ({{verifiable-data-structure-registry}}) defining the integers used to identify verifiable data structures.

TBD_2 (requested assignment 396):

: A COSE header parameter named `vdp` (short for "verifiable data structure proofs"), which conveys a map containing verifiable data structure proofs organized by proof type.
  Correspondingly, this document introduces a new registry ({{verifiable-data-structure-proofs-registry}}) defining the integers used to identify verifiable data structure proof types.

# Terminology

CDDL:
: Concise Data Definition Language (CDDL) is defined in {{RFC8610}}.

EDN:
: CBOR Extended Diagnostic Notation (EDN) is defined in {{RFC8949}}, where it is referred to as "diagnostic notation", and is revised in {{-cbor-edn-literals}}.

Verifiable Data Structure (VDS):

: A data structure which supports one or more Verifiable Data Structure Proof Types.
  This property describes an algorithm used to maintain a verifiable data structure, for example a binary Merkle tree algorithm.

Verifiable Data Structure Proofs (VDP):

: A data structure used to convey proof types for proving different properties, such as authentication, inclusion, consistency, and freshness.
  Parameters can include multiple proofs of a given type, or multiple types of proof (inclusion and consistency).

Proof Type:

: A property that can be obtained by verifying a given proof over one or more entries in a Verifiable Data Structure.
  For example, a VDS, such as a binary Merkle tree, can support proofs of type "inclusion" where each proof confirms that a given entry is included in a Merkle root.

Proof Value:

: An encoding of a Proof Type in CBOR {{-CBOR}}.

Entry:

: An entry in a verifiable data structure for which proofs can be derived.

Receipt:

: A COSE object, as defined in {{RFC9052}}, containing the header parameters necessary to convey VDP for an associated VDS.

# Verifiable Data Structures in CBOR {#sec-generic-verifiable-data-structures}

This section describes representations of verifiable data structure proofs in {{-CBOR}}.
For example, construction of a Merkle tree leaf, or an inclusion proof from a leaf to a Merkle root, might have several different representations, depending on the verifiable data structure used.
Differences in representations are necessary to support efficient verification, unique security or privacy properties, and for compatibility with specific implementations.
This document defines two extension points for enabling verifiable data structures with COSE and provides concrete examples for the structures and proofs defined in {{Section 2.1.3 of RFC9162}} and {{Section 2.1.4 of RFC9162}}.
The design of these structures is influenced by the conventions established for COSE Keys.

## Structures {#sec-cose-verifiable-data-structures}

Similar to [COSE Key Types](https://www.iana.org/assignments/cose/cose.xhtml#key-type), different verifiable data structures support different algorithms.

This document establishes a registry of verifiable data structure algorithms, see {{verifiable-data-structure-registry}} for details.

## Proofs {#sec-cose-verifiable-data-structure-proofs}

Similar to [COSE Key Type Parameters](https://www.iana.org/assignments/cose/cose.xhtml#key-type-parameters), as EC2 keys (1: 2) keys require and give meaning to specific parameters, such as -1 (crv), -2 (x), -3 (y), -4 (d), RFC9162_SHA256 (TBD_1 (requested assignment 395) : 1) supports both (-1) inclusion and (-2) consistency proofs.

This document establishes a registry of verifiable data structure algorithm proofs, see {{verifiable-data-structure-proofs-registry}} for details.

Proof types are specific to their associated "verifiable data structure", for example, different Merkle trees might support different representations of "inclusion proof" or "consistency proof".
Implementers should not expect interoperability across "verifiable data structures".
Security analysis MUST be conducted prior to migrating to new structures to ensure the new security and privacy assumptions are acceptable for the use case.

## Usage {#receipt-spec}

This document registers a new COSE Header Parameter `receipts` (TBD_0 (requested assignment 394)) to enable Receipts to be conveyed in the protected and unprotected headers of COSE Objects.

When the receipts header parameter is present, the verifier MUST confirm that the associated verifiable data structure and verifiable data structure proofs match entries present in the registries established in this specification, including values added in subsequent registrations..

Receipts MUST be tagged as COSE_Sign1.

The following {{-CDDL}} definition is provided:

~~~ cddl
Signature_With_Receipt = #6.18(COSE_Sign1)

cose-value = any

Protected_Header = {
  * cose-label => cose-value
}

Unprotected_Header = {
  &(receipts: 394)  => [+ bstr .cbor Receipt]
  * cose-label => cose-value
}

COSE_Sign1 = [
  protected   : bstr .cbor Protected_Header,
  unprotected : Unprotected_Header,
  payload     : bstr / nil,
  signature   : bstr
]

Receipt = Receipt_For_Inclusion / Receipt_For_Consistency

; Note the the proof formats shown here are for RFC9162_SHA256.
; Other verifiable data structures may have different proof formats.

Receipt_For_Inclusion = #6.18(Signed_Inclusion_Proof)

Receipt_For_Consistency = #6.18(Signed_Consistency_Proof)

Signed_Inclusion_Proof = [
  protected   : bstr .cbor Signed_Inclusion_Protected_Header,
  unprotected : Signed_Inclusion_Unprotected_Header,
  payload     : bstr / nil, ; Merkle tree root
  signature   : bstr
]

Signed_Consistency_Proof = [
  protected   : bstr .cbor Signed_Consistency_Protected_Header,
  unprotected : Signed_Consistency_Unprotected_Header,
  payload     : bstr / nil, ; Newer Merkle tree root
  signature   : bstr
]

Signed_Inclusion_Protected_Header = {
  &(alg: 1) => int
  &(vds: 395) => int
  * cose-label => cose-value
}

Signed_Consistency_Protected_Header = {
  &(alg: 1) => int
  &(vds: 395) => int
  * cose-label => cose-value
}

Signed_Inclusion_Unprotected_Header = {
  &(vdp: 396) => Signed_Inclusion_Verifiable_Proofs
  * cose-label => cose-value
}

Signed_Consistency_Unprotected_Header = {
  &(vdp: 396) => Signed_Consistency_Verifiable_Proofs
  * cose-label => cose-value
}

Signed_Inclusion_Verifiable_Proofs = {
  &(inclusion-proof: -1) => Signed_Inclusion_Inclusion_Proofs
  * cose-label => cose-value
}

Signed_Consistency_Verifiable_Proofs = {
  &(consistency-proof: -2) => Signed_Consistency_Consistency_Proofs
  * cose-label => cose-value
}

Signed_Inclusion_Inclusion_Proofs = [ + Signed_Inclusion_Inclusion_Proof ]

Signed_Consistency_Consistency_Proofs = [ + Signed_Consistency_Consistency_Proof ]

Signed_Inclusion_Inclusion_Proof = bstr .cbor [
  / tree-size / uint,
  / leaf-index / uint,
  / inclusion-path / [ + bstr ]
]

Signed_Consistency_Consistency_Proof = bstr .cbor [
  / tree-size-1 / uint,
  / tree-size-2 / uint,
  / consistency-path / [ + bstr ]
]

~~~
{: #fig-receipts-cddl title="CDDL for a COSE Sign1 with attached receipts"}

The following informative EDN is provided:

~~~ cbor-diag
/ cose-sign1 / 18([
  / protected   / <<{
    / kid / 4 : h'bc297b51...e4edf0de',
    / algorithm / 1 : -7,  # ES256
  }>>,
  / unprotected / {
    / receipts / 394 : {
      <</ cose-sign1 / 18([
        / protected   / <<{
          / kid / 4 : h'abcdef12...34567890',
          / algorithm / 1 : -7,  # ES256
          / vds       / 395 : 1, # RFC9162 SHA-256
        }>>,
        / unprotected / {
          / proofs / 396 : {
            / inclusion / -1 : [
              <<[
                / size / 9, / leaf / 8,
                / inclusion path /
                h'7558a95f...e02e35d6'
              ]>>
            ],
          },
        },
        / payload     / null,
        / signature   / h'02d227ed...ccd3774f'
      ])>>,
      <</ cose-sign1 / 18([
        / protected   / <<{
          / kid / 4 : h'abcdef12...34567890',
          / algorithm / 1 : -7,  # ES256
          / vds       / 395 : 1, # RFC9162 SHA-256
        }>>,
        / unprotected / {
          / proofs / 396 : {
            / inclusion / -1 : [
              <<[
                / size / 6, / leaf / 5,
                / inclusion path /
                h'9352f974...4ffa7ce0',
                h'54806f32...f007ea06'
              ]>>
            ],
          },
        },
        / payload     / null,
        / signature   / h'36581f38...a5581960'
      ])>>
    },
  },
  / payload     / h'0167c57c...deeed6d4',
  / signature   / h'2544f2ed...5840893b'
])
~~~
{: #fig-receipts-edn title="An example COSE Signature with multiple receipts"}

The specific structure of COSE Receipts is dependent on the structure of the COSE_Sign1 payload and the verifiable data structure proofs contained in the COSE_Sign1 unprotected header.
The CDDL definition for verifiable data structure proofs is specific to each verifiable data structure.
This document describes proofs for RFC9162_SHA256 in the following sections.

## Profiles {#profiles-def}

New verifiable data structures can require the definition of a profile.
The payload in such definitions SHOULD be detached.
Detached payloads force verifiers to recompute the root from the proof and protect against implementation errors where the signature is verified but the payload is incompatible with the proof.
Profiles of proof signatures that define additional protected header parameters are encouraged to make their presence mandatory to ensure that claims are processed with their intended semantics.
One way to include this information in the COSE structure is use of the typ (type) Header Parameter, see {{-cose-typ}} and the similar guidance provided in {{-cwt-header-claims}}.

### Registration Requirements

Each verifiable data structure specification applying for inclusion in this registry MUST define how to encode the verifiable data structure identifier and its proof types in CBOR.
Each specification MUST define how to produce and consume the supported proof types.
See {{sec-rfc-9162-verifiable-data-structure-definition}} as an example.

Where a specification supports a choice of hash algorithm, a separate IANA registration must be made for each supported algorithm.
For example, to provide support for SHA256 and SHA3_256 with Merkle Consistency and Inclusion Proofs defined respectively in {{Section 2.1.3 of RFC9162}} and {{Section 2.1.4 of RFC9162}}, both "RFC9162_SHA256" and "RFC9162_SHA3_256" require entries in the relevant IANA registries.
This document only defines "RFC9162_SHA256".

# RFC9162_SHA256 {#sec-rfc-9162-verifiable-data-structure-definition}

This section defines how the data structure described in {{Section 2.1 of RFC9162}} is mapped to the terminology defined in this document, using {{-CBOR}} and {{-COSE}}.

## Verifiable Data Structure

The integer identifier for this Verifiable Data Structure is 1.
The string identifier for this Verifiable Data Structure is "RFC9162_SHA256", a Merkle Tree where SHA256 is used as the hash algorithm.
See {{verifiable-data-structure-proofs-registry}}.
See {{Section 2.1.1 of RFC9162}} (Definition of the Merkle Tree), for a complete description of this verifiable data structure.

## Inclusion Proof {#sec-rfc9162-sha256-inclusion-proof}

See {{Section 2.1.3.1 of RFC9162}} (Generating an Inclusion Proof), for a complete description of this verifiable data structure proof type.

The CBOR representation of an inclusion proof for RFC9162_SHA256 is:

~~~~ cddl
inclusion-proof = bstr .cbor [

    ; tree size at current Merkle root
    tree-size: uint

    ; index of leaf in tree
    leaf-index: uint

    ; path from leaf to current Merkle root
    inclusion-path: [ + bstr ]
]
~~~~
{: #rfc9162-sha256-cbor-inclusion-proof align="left" title="CBOR Encoded RFC9162 Inclusion Proof"}

The term `leaf-index` is used for alignment with the use established in {{Section 2.1.3.2 of RFC9162}}.

Note that {{RFC9162}} defines inclusion proofs only for leaf nodes, and that:

> If leaf_index is greater than or equal to tree_size, then fail the proof verification.

The identifying index of a leaf node is relative to all nodes in the tree size for which the proof was obtained.

### Receipt of Inclusion

In a signed inclusion proof, the payload is the Merkle tree root that corresponds to the log at size `tree-size`.
The protected header for an RFC9162_SHA256 inclusion proof signature is:

~~~~ cddl
protected-header-map = {
  &(alg: 1) => int
  &(vds: 395) => int
  * cose-label => cose-value
}
~~~~
{: #vds-in-inclusion-receipt-protected-header align="left" title="Protected Header for a Receipt of Inclusion"}

- alg (label: 1): REQUIRED. Signature algorithm identifier. Value type: int.
- vds (label: TBD_1 (requested assignment 395)): REQUIRED. Verifiable data structure algorithm identifier. Value type: int.

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

- vdp (label: TBD_2 (requested assignment 396)): REQUIRED. Verifiable data structure proofs. Value type: Map.
- inclusion-proof (label: -1): REQUIRED. Inclusion proofs. Value type: Array of bstr.

The payload of an RFC9162_SHA256 inclusion proof signature is the Merkle tree hash as defined in {{RFC9162}}.

An EDN example for a Receipt containing an inclusion proof for RFC9162_SHA256 with a detached payload (see {{profiles-def}}) is:

~~~~ cbor-diag
/ cose-sign1 / 18([
  / protected   / <<{
    / algorithm / 1 : -7,  # ES256
    / vds       / 395 : 1, # RFC9162 SHA-256
  }>>,
  / unprotected / {
    / proofs / 396 : {
      / inclusion / -1 : [
        <<[
          / size / 20, / leaf / 17,
          / inclusion path /
          h'fc9f050f...221c92cb',
          h'bd0136ad...6b28cf21',
          h'd68af9d6...93b1632b'
        ]>>
      ],
    },
  },
  / payload     / null,
  / signature   / h'de24f0cc...9a5ade89'
])
~~~~
{: #rfc9162_sha256_inclusion_receipt align="left" title="Receipt of Inclusion"}

The VDS in the protected header is necessary to understand the inclusion proof structure in the unprotected header.

The inclusion proof and signature are verified in order.
First the verifier applies the inclusion proof to a possible entry (set member) bytes.
If this process fails, the inclusion proof may have been tampered with.
If this process succeeds, the result is a Merkle root, which in the attached as the COSE Sign1 payload.
Second the verifier checks the signature of the COSE Sign1.
If the resulting signature verifies, the Receipt has proved inclusion of the entry in the verifiable data structure.
If the resulting signature does not verify, the signature may have been tampered with.

## Consistency Proof {#sec-rfc9162-sha256-consistency-proof}

See {{Section 2.1.4.1 of RFC9162}} (Generating a Consistency Proof), for a complete description of this verifiable data structure proof type.

The cbor representation of a consistency proof for RFC9162_SHA256 is:

~~~~ cddl
consistency-proof =  bstr .cbor [

    ; older Merkle root tree size
    tree-size-1: uint

    ; newer Merkle root tree size
    tree-size-2: uint

    ; path from older Merkle root to newer Merkle root.
    consistency-path: [ + bstr ]

]
~~~~
{: #rfc9162_sha256_consistency_proof align="left" title="CBOR Encoded RFC9162 Consistency Proof"}

### Receipt of Consistency

In a signed consistency proof, the newer Merkle tree root (proven to be consistent with an older Merkle tree root) is an attached payload and corresponds to the log at size tree-size-2.

The protected header for an RFC9162_SHA256 consistency proof signature is:

~~~~ cddl
protected-header-map = {
  &(alg: 1) => int
  &(vds: 395) => int
  * cose-label => cose-value
}
~~~~
{: #vds-in-consistency-receipt-protected-header align="left" title="Protected Header for a Receipt of Consistency"}

- alg (label: 1): REQUIRED. Signature algorithm identifier. Value type: int.
- vds (label: TBD_1 (requested assignment 395)): REQUIRED. Verifiable data structure algorithm identifier. Value type: int.

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

- vdp (label: TBD_2 (requested assignment 396)): REQUIRED. Verifiable data structure proofs. Value type: Map.
- consistency-proof (label: -2): REQUIRED. Consistency proofs. Value type: Array of bstr.

The payload of an RFC9162_SHA256 consistency proof signature is:
The newer Merkle tree hash as defined in {{RFC9162}}.

An example EDN for a Receipt containing a consistency proof for RFC9162_SHA256 with a detached payload (see {{profiles-def}}) is:

~~~~ cbor-diag
/ cose-sign1 / 18([
  / protected   / <<{
    / algorithm / 1 : -7,  # ES256
    / vds       / 395 : 1, # RFC9162 SHA-256
  }>>,
  / unprotected / {
    / proofs / 396 : {
      / consistency / -2 : [
        <<[
          / old / 20, / new / 104,
          / consistency path /
          h'e5b3e764...c4a813bc',
          h'87e8a084...4f529f69',
          h'f712f76d...92a0ff36',
          h'd68af9d6...93b1632b',
          h'249efab6...b7614ccd',
          h'85dd6293...38914dc1'
        ]>>
      ],
    },
  },
  / payload     / null,
  / signature   / h'94469f73...52de67a1'
])
~~~~
{: #rfc9162_sha256_consistency_receipt align="left" title="Example consistency receipt"}

The VDS in the protected header is necessary to understand the consistency proof structure in the unprotected header.

The signature and consistency proof are verified in order.

First the verifier checks the signature on the COSE Sign1.
If the verification fails, the consistency proof is not checked.
Second the consistency proof is checked by applying a previous inclusion proof, to the consistency proof.
If the verification fails, the append only property of the verifiable data structure is not assured.
This approach is specific to RFC9162_SHA256, different verifiable data structures may not support consistency proofs.
It is recommended that implementations return a single boolean result for Receipt verification operations, to reduce the chance of accepting a valid signature over an invalid consistency proof.

# Privacy Considerations

The privacy considerations section of {{RFC9162}} and {{-COSE}} apply to this document.

## Log Length

Some structures and proofs leak the size of the log at the time of inclusion.
In the case that a log only stores certain kinds of information, this can reveal details that could impact reputation.
For example, if a transparency log only stored breach notices, a receipt for a breach notice would reveal the number of previous breaches at the time the notice was made transparent.

## Header Parameters

Additional header parameters can reveal information about the transparency service or its log entries.
The receipt producer MUST perform a privacy analysis for all mandatory fields in profiles based on this specification.

# Security Considerations

See the security considerations section of:

- {{RFC9162}}
- {{-COSE}}

## Choice of Signature Algorithms

A security analysis ought to be performed to ensure that the digital signature algorithm `alg` has the appropriate strength to secure receipts.

It is recommended to select signature algorithms that share cryptographic components with the verifiable data structure used, for example:
Both RFC9162_SHA256 and ES256 depend on the sha-256 hash function.

## Validity Period

In some cases, receipts MAY include strict validity periods, for example, activation not too far in the future, or expiration, not too far in the past.
See the `iat`, `nbf`, and `exp` claims in {{-CWT}}, for one way to accomplish this.
The details of expressing validity periods are out of scope for this document.

## Status Updates

In some cases, receipts should be "revocable" or "suspendible", after being issued, regardless of their validity period.
The details of expressing statuses are out of scope for this document.

# IANA Considerations

## COSE Header Parameter

IANA is requested to add the COSE header parameters defined in {{param-list}}, as listed in {{iana-header-params}}, to the "COSE Header Parameters" registry {{!IANA.cose_header-parameters}} in the 'Integer values from 256 to 65535' range ('Specification Required' Registration Procedure).
The Value Registry for "vds" is the COSE Verifiable Data Structure registry.
The map labels in the "vdp" are assigned from the COSE Verifiable Data Structure Proofs registry.

| Name       | Label                             | Value Type | Value Registry | Description                                                                                                     | Reference                 |
|------------|-----------------------------------|------------|----------------|-----------------------------------------------------------------------------------------------------------------|---------------------------|
| `receipts` | TBD_0 (requested assignment: 394) | array      |                | Priority ordered sequence of CBOR encoded Receipts                                                              | {{&SELF}}, {{param-list}} |
| `vds`      | TBD_1 (requested assignment: 395) | int        | COSE Verifiable Data Structure | Algorithm identifier for verifiable data structures, used to produce verifiable data structure proofs | {{&SELF}}, {{param-list}} |
| `vdp`      | TBD_2 (requested assignment: 396) | map        | map key in COSE Verifiable Data Structure Proofs | Location for verifiable data structure proofs in COSE Header Parameters                                     | {{&SELF}}, {{param-list}} |
{: #iana-header-params title="Newly registered COSE Header Parameters"}

## Verifiable Data Structure Registries

IANA established the COSE Verifiable Data Structure Algorithms and COSE Verifiable Data Structure Proofs registries under a Specification Required policy as described in {{Section 4.6 of RFC8126}}.

### Expert Review
Expert reviewers should take into consideration the following points:

- Experts are advised to assign the next available positive integer for verifiable data structures.

- Point squatting should be discouraged.
Reviewers are encouraged to get sufficient information for registration requests to ensure that the usage is not going to duplicate one that is already registered, and that the point is likely to be used in deployments.

- Specifications are required for all point assignments.
Early Allocation is permissible, see Section 2 of {{RFC7120}}.

- It is not permissible to assign points in COSE Verifiable Data Structure Algorithms, for which no corresponding COSE Verifiable Data Structure Proofs entry exists, and vice versa.

- The Change Controller for related registrations of structures and proofs should be the same.

### COSE Verifiable Data Structure Algorithms {#verifiable-data-structure-registry}

Registration Template:

- Name:
  This is a descriptive name for the verifiable data structure that enables easier reference to the item.

- Value:
  This is the value used to identify the verifiable data structure.

- Description:
  This field contains a brief description of the verifiable data structure.

- Reference:
  This contains a pointer to the public specification for the verifiable data structure.

- Change Controller:
  For Standards Track RFCs, list the "IETF".  For others, give the name of the responsible party.  Other details (e.g., postal address, email address, home page URI) may also be included.

Initial contents:

| Name            | Value | Description                      | Reference
|---
| Reserved        | 0     | Reserved                         | Reserved
| RFC9162_SHA256  | 1     | SHA256 Binary Merkle Tree        | {{Section 2.1 of RFC9162}}
{: #verifiable-data-structure-proofs-registry align="left" title="COSE Verifiable Data Structure Algorithms"

### COSE Verifiable Data Structure Proofs {#verifiable-data-structure-proofs-registry}

Registration Template:

- Verifiable Data Structure:
  This value used identifies the related verifiable data structure.

- Name:
  This is a descriptive name for the proof type that enables easier reference to the item.

- Label:
  This is the value used to identify the verifiable data structure proof type.

- CBOR Type:
  This contains the CBOR type for the value portion of the label.

- Description:
  This field contains a brief description of the proof type.

- Reference:
  This contains a pointer to the public specification for the proof type.

- Change Controller:
  For Standards Track RFCs, list the "IETF".  For others, give the name of the responsible party.  Other details (e.g., postal address, email address, home page URI) may also be included.

Initial contents:

| Verifiable Data Structure | Name               | Label | CBOR Type        | Description                   | Reference
|---
| 1                         | inclusion proofs   | -1    | array (of bstr)  | Proof of inclusion            | {{&SELF}}, {{sec-rfc9162-sha256-inclusion-proof}}
| 1                         | consistency proofs | -2    | array (of bstr)  | Proof of append only property | {{&SELF}}, {{sec-rfc9162-sha256-consistency-proof}}
{: #cose-verifiable-data-structure-proofs align="left" title="COSE Verifiable Data Structure Proofs"}

# Acknowledgements {#Acknowledgements}

We would like to thank
Maik Riechert,
Jon Geater,
Michael B. Jones,
Mike Prorock,
Ilari Liusvaara,
Amaury Chamayou,
for their contributions (some of which substantial) to this draft and to the initial set of implementations.

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

## Transmute Prototype

An open-source implementation was initiated and is maintained by the Transmute Industries Inc. - Transmute.
An application demonstrating the concepts is available at [COSE SCITT Receipts](https://github.com/transmute-industries/cose?tab=readme-ov-file#transparent-statement)

Implementation URL: https://github.com/transmute-industries/cose
Maturity: The code's level of maturity is considered to be "prototype".
Coverage and Version Compatibility: The current version ('main') implements the verifiable data structure algorithm, inclusion proof and consistency proof concepts of this draft.
License: The project and all corresponding code and data maintained on GitHub are provided under the Apache License, version 2.
Contact: Orie Steele (orie@transmute.industries)
