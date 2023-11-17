---
v: 3

title: Concise Encoding of Signed Merkle Tree Proofs
abbrev: CoMETRE
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
  RFC8949:
  RFC6962: certificate-transparency-v1
  RFC9162: certificate-transparency-v2
  RFC6234:
  RFC8032:
  RFC6979:
  RFC7049: CBOR
  RFC9053: COSE
  RFC8126: iana-considerations-guide
  BCP205: RFC7942

informative:
  I-D.ietf-cose-countersign:
  I-D.ietf-scitt-architecture: scitt-architecture


--- abstract

This specification describes verifiable data structures and associated proof types for use with COSE.
The extensibility of the approach is demonstrated by providing CBOR encodings for RFC9162.

--- middle

# Introduction

Merkle trees are one of many verifiable data structures that enable tamper evident secure information storage,
through their ability to protect the integrity of batches of documents or collections of statements.

Merkle trees can be constructed from simple operations such as concatenation and digest via a cryptographic hash function,
however, more advanced constructions enable proofs of different properties of the underlying verifiable data structure.

Verifiable data structure proofs can be used to prove a document is in a database (proof of inclusion),
that a database is append only (proof of consistency), that a smaller set of statements are contained
in a large set of statements (proof of disclosure, a special case of proof of inclusion),
or proof that certain data is not yet present in a database (proofs of non inclusion).

Differences in the representation of verifiable data structures, and verifiable data structure proof types,
can increase the burden for implementers, and create interoperability challenges for transparency services.

This document describes how to convey verifiable data structures, and associated proof types in COSE envelopes.

## Requirements Notation

{::boilerplate bcp14-tagged}

# CBOR Tags

This section will be removed before the document is completed,
its purpose is to track the TBD code points references throughout the draft.

-111 is TBD_1:

: A requested cose header parameter representing the verifiable data structure used.

-222 is TBD_2:

: A requested cose header parameter representing the verifiable data structure parameters map (proofs map)

The other codepoints are assigned from the registries established in this draft, they are therefore not marked TBD.

# Terminology

Verifiable Data Structure:

: A data structure which supports one or more Proof Types.

Proof Type:

: A verifiable process, that proves properties of one or more Verifiable Data Structures.

Proof Value:

: An encoding of a Proof Type in CBOR.

Proof Signature:

: A COSE Sign1 encoding of a specific Proof Type for a specific Verifiable Data Structure.

# Verifiable Data Structures in CBOR {#sec-generic-verifiable-data-structures}

This section describes representations of verifiable data structure proofs structures in CBOR.

Different verifiable data structures support the same proof types,
but the representations of the proofs varies greatly.

For example, construction of a merkle tree leaf, or an inclusion proof from a leaf to a merkle root,
might have several different representations, depending on the verifiable data structure used.

Some differences in representations are necessary to support efficient
verification of different kinds of proofs and for compatibility with specific implementations.

Some proof types benefit from standard envelope formats for signing and encryption, whilst others require no further cryptographic intervention at all.

In order to improve interoperability we define two extension points for
enabling verifiable data structures with COSE, and we provide concrete examples for
the structures and proofs defined in {{-certificate-transparency-v2}}.

## COSE Verifiable Data Structures {#sec-cose-verifiable-data-structures}

Similar to [COSE Key Types](https://www.iana.org/assignments/cose/cose.xhtml#key-type),
different verifiable data structures support different algorithms.
As EC2 keys (1: 2) support both digital signature and key agreement algorithms,
RFC9162_SHA256 (TBD_1 : 1) supports both inclusion and consistency proofs.

This document establishes a registry of verifiable data structure algorithms,
with the following initial contents:

* Name: The name of the verifiable data structure
* Value: The identifier for the verifiable data structure
* Description: The identifier for the verifiable data structure
* Reference: Where the verifiable data structure is defined

| Name            | Value | Description                      | Reference
|---
| N/A             | 0     | N/A                              | N/A
| RFC9162_SHA256  | 1     | SHA256 Binary Merkle Tree        | {{-certificate-transparency-v2}}
{: #cose-verifiable-data-structures align="left" title="COSE Verifiable Data Structures"}

When desigining new verifiable data structures,
please request the next available positive integer as your requested assignment,
for example:


| Name            | Value | Description                      | Reference
|---
| N/A             | 0     | N/A                              | N/A
| RFC9162_SHA256  | 1     | SHA256 Binary Merkle Tree        | {{-certificate-transparency-v2}}
| Your name       | TBD (requested assignment 2) | tbd       | Your specification


## COSE Verifiable Data Structure Parameters {#sec-cose-verifiable-data-structure-parameters}

Similar to [COSE Key Type Parameters](https://www.iana.org/assignments/cose/cose.xhtml#key-type-parameters),
As EC2 keys (1: 2) keys require and give meanding to specific parameters, such as -1 (crv), -2 (x), -3 (y), -4 (d),
RFC9162_SHA256 (TBD_1 : 1) supports both (-1) inclusion and (-2) consistency proofs.

This document establishes a registry of verifiable data structure algorithms,
with the following initial contents:

| Verifiable Data Structure | Name               | Label | CBOR Type        | Description                   | Reference
|---
| 1                         | inclusion proofs   | -1    | array (of bstr)  | Proof of inclusion            | {{sec-rfc9162-sha256-inclusion-proof}}
| 1                         | consistency proofs | -2    | array (of bstr)  | Proof of append only property | {{sec-rfc9162-sha256-consistency-proof}}
{: #cose-verifiable-data-structures-parameters align="left" title="COSE Verifiable Data Structure Parameters"}

Proof types are specific to their associated "verifiable data structure",
for example, different Merkle trees might support different representations of "inclusion proof" or "consistency proof".

Implementers should not expect interoperability accross "verifiable data structures",
but they should expect conceptually similar properties across the different registered proof type.

For example, 2 different merkle tree based verifiable data structures might both support proofs of inclusion.

Protocols requiring proof of inclusion ought to be able to preserve their functionality,
while switching from one verifiable data structure to another, so long as both structures support the same proof types.

When desigining new verifiable data structure parameters (or proof types),
please start with -1, and count down for each proof type supported by your verifiable data structure:

| Verifiable Data Structure | Name               | Label | CBOR Type        | Description                   | Reference
|---
| 1                           | inclusion proofs   | -1    | array (of bstr)  | Proof of inclusion            | {{sec-rfc9162-sha256-inclusion-proof}}
| 1                           | consistency proofs | -2    | array (of bstr)  | Proof of append only property | {{sec-rfc9162-sha256-consistency-proof}}
|TBD (requested assignment 2) | new proof type     | -1    | tbd              | tbd                           | Your_Specification
|TBD (requested assignment 2) | new proof type     | -2    | tbd              | tbd                           | Your_Specification
|TBD (requested assignment 2) | new proof type     | -3    | tbd              | tbd                           | Your_Specification

### Registration Requirements

Each specification MUST define how to encode the verifiable data structure and its parameters (also called proof types) in CBOR.

Each specification MUST define how to produce and consume the supported proof types.

See {{sec-rfc-9162-verifiable-data-structure-definition}} as an example.

# RFC9162_SHA256 {#sec-rfc-9162-verifiable-data-structure-definition}

This section defines how the data structures described in {{-certificate-transparency-v2}}
are mapped to the terminology defined in this document, using cbor and cose.

## Verifiable Data Structure

The integer identifier for this Verifiable Data Structure is 1.
The string identifier for this Verifiable Data Structure is "RFC9162_SHA256".

See {{cose-verifiable-data-structures}}.

See {{-certificate-transparency-v2}}, 2.1.1. Definition of the Merkle Tree,
for a complete description of this verifiable data structure.

## Inclusion Proof {#sec-rfc9162-sha256-inclusion-proof}

See {{-certificate-transparency-v2}}, 2.1.3.1. Generating an Inclusion Proof,
for a complete description of this verifiable data structure proof type.

The cbor representation of an inclusion proof for RFC9162_SHA256 is:

~~~~ cddl
inclusion-proof = [
    tree-size: int
    leaf-index: int
    inclusion-path: [ + bstr ]
]
~~~~

### Inclusion Proof Signature

In a signed inclusion proof, the previous merkle tree root, maps to tree-size-1, and is a detached payload.

Other specifications refer to signed inclusion proofs as "receipts",
profiles of proof signatures are encouraged to make additional protected header parameters mandatory.

TODO: reference to scitt receipts.

The protected header for an RFC9162_SHA256 inclusion proof signature is:

* alg (label: 1): REQUIRED. Signature algorithm identifier. Value type: int / tstr.
* verifiable-data-structure (label: -111): REQUIRED. verifiable data structure algorithm identifier. Value type: int / tstr.

The unprotected header for an RFC9162_SHA256 inclusion proof signature is:

~~~~ cddl

inclusion-proofs = [ + bstr ]

verifiable-proofs = {
  &(inclusion-proof: -1) => inclusion-proofs
}

unprotected-header-map = {
  &(verifiable-data-proof: -222) => verifiable-proofs
  * cose-label => cose-value
}
~~~~

* inclusion-proof (label: -1): REQUIRED.

The payload of an RFC9162_SHA256 inclusion proof signature is the previous Merkle tree hash as defined in {{-certificate-transparency-v2}}.

The payload MUST be detached.

Detaching the payload forces verifiers to recompute the root from the inclusion proof signature,
this protects against implementation errors where the signature is verified but the root does not match the inclusion proof.

~~~~ cbor-diag
18(                                 / COSE Sign 1                   /
    [
      h'a4012604...6d706c65',       / Protected                     /
      {                             / Unprotected                   /
        -222: {                     / Proofs                        /
          -1: [                     / Inclusion proofs (1)          /
            h'83080783...32568964', / Inclusion proof 1             /
          ]
        },
      },
      h'',                          / Detached payload              /
      h'2e34df43...8d74d55e'        / Signature                     /
    ]
)
~~~~

~~~~ cbor-diag
{                                   / Protected                     /
  1: -7,                            / Algorithm                     /
  4: h'4930714e...7163316b',        / Key identifier                /
  -111: 1,                          / Verifiable Data Structure     /
}
~~~~

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

## Consistency Proof {#sec-rfc9162-sha256-consistency-proof}

See {{-certificate-transparency-v2}}, 2.1.4.1. Generating a Consistency Proof,
for a complete description of this verifiable data structure proof type.

The cbor representation of a consistency proof for RFC9162_SHA256 is:

~~~~ cddl
consistency-proof = [
    tree-size-1: int ; size of tree, at previous root
    tree-size-2: int ; size of tree, at latest root
    consistency-path: [ + bstr ] ; path from previous to latest root.
]
~~~~

Editors note: tree-size-1, could be ommited, if an inclusion-proof is always present, since the inclusion proof contains, tree-size-1.

### Consistency Proof Signature

In a signed consistency proof, the latest merkle tree root, maps to tree-size-2, and is an attached payload.

The protected header for an RFC9162_SHA256 consistency proof signature is:

* alg (label: 1): REQUIRED. Signature algorithm identifier. Value type: int / tstr.
* verifiable-data-structure (label: TBD_1): REQUIRED. verifiable data structure algorithm identifier. Value type: int / tstr.

The unprotected header for an RFC9162_SHA256 consistency proof signature is:

~~~~ cddl

consistency-proofs = [ + bstr ]

verifiable-proofs = {
  &(consistency-proof: -2) => consistency-proofs
}

unprotected-header-map = {
  &(verifiable-data-proof: -222) => verifiable-proofs
  * cose-label => cose-value
}
~~~~

* consistency-proof (label: -2): REQUIRED.

The payload of an RFC9162_SHA256 consistency proof signature is:

The latest Merkle tree hash as defined in {{-certificate-transparency-v2}}.

The payload MUST be attached.

~~~~ cbor-diag
18(                                 / COSE Sign 1                   /
    [
      h'a3012604...392b6601',       / Protected                     /
      {                             / Unprotected                   /
        -222: {                     / Proofs                        /
          -2: [                     / Consistency proofs (1)        /
            h'83040682...2e73a8ab', / Consistency proof 1           /
          ]
        },
      },
      h'430b6fd7...f74c7fc4',       / Payload                       /
      h'd97befea...f30631cb'        / Signature                     /
    ]
)
~~~~

~~~~ cbor-diag
{                                   / Protected                     /
  1: -7,                            / Algorithm                     /
  4: h'68747470...6d706c65',        / Key identifier                /
  -111: 1,                          / Verifiable Data Structure     /
}
~~~~

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

# Privacy Considerations

See the privacy considerations section of:

- {{-certificate-transparency-v2}}
- {{-COSE}}

# Security Considerations

See the security considerations section of:

- {{-certificate-transparency-v2}}
- {{-COSE}}

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

This document requests IANA to add new values to the 'COSE
Algorithms' and to the 'COSE Header Algorithm Parameters' registries
in the 'Standards Action With Expert Review category.

#### COSE Header Algorithm Parameters

* Name: verifiable-data-structure
* Label: TBD_1
* Value type: int / tstr
* Value registry: https://www.iana.org/assignments/cose/cose.xhtml#header-parameters
* Description: Algorithm name for verifiable data structure, used to produce verifiable data structure proofs.

* Name: verifiable-data-structure-parameters
* Label: TBD_2
* Value type: int / tstr
* Value registry: https://www.iana.org/assignments/cose/cose.xhtml#header-parameters
* Description: Location for verifiable data structure proofs in COSE Header Parameters.

### COSE Verifiable Data Structures {#verifiable-data-structure-registry}

IANA will be asked to establish a registry of verifiable data structure identifiers,
named "COSE Verifiable Data Structures" to be administered under a Specification Required policy {{-iana-considerations-guide}}.

Template:

* Name: The name of the verifiable data structure
* Value: The identifier for the verifiable data structure
* Description: The identifier for the verifiable data structure
* Reference: Where the verifiable data structure is defined

Initial contents: Provided in {{cose-verifiable-data-structures}}

### COSE Verifiable Data Structure Parameters {#verifiable-data-structure-parameters-registry}

IANA will be asked to establish a registry of verifiable data structure parameters,
named "COSE Verifiable Data Structure Parameters" to be administered under a Specification Required policy {{-iana-considerations-guide}}.

Template:

* Verifiable Data Structure: The identifier for the verifiable data structure
* Name: The name of the proof type
* Label: The integer of the proof type
* CBOR Type: The cbor data type of the proof
* Description: The description of the proof type
* Reference: Where the proof type is defined

Initial contents: Provided in {{cose-verifiable-data-structures-parameters}}

--- back

# Implementation Status

Note to RFC Editor: Please remove this section as well as references to {{BCP205}} before AUTH48.

This section records the status of known implementations of the protocol defined by this specification at the time of posting of this Internet-Draft, and is based on a proposal described in {{BCP205}}.
The description of implementations in this section is intended to assist the IETF in its decision processes in progressing drafts to RFCs.
Please note that the listing of any individual implementation here does not imply endorsement by the IETF.
Furthermore, no effort has been spent to verify the information presented here that was supplied by IETF contributors.
This is not intended as, and must not be construed to be, a catalog of available implementations or their features.
Readers are advised to note that other implementations may exist.

According to {{BCP205}},
"this will allow reviewers and working groups to assign due consideration to documents that have the benefit of running code, which may serve as evidence of valuable experimentation and feedback that have made the implemented protocols more mature.
It is up to the individual working groups to use this information as they see fit".

## Implementer

An open-source implementation was initiated and is maintained by the Transmute Industries Inc. - Transmute.

## Implementation Name

An application demonstrating the concepts is available at [https://scitt.xyz](https://scitt.xyz).

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

The implementation builds on concepts described in SCITT {{-scitt-architecture}} (https://scitt.io/).

The implementation uses the Concise Binary Object Representation {{-CBOR}} (https://cbor.io/).

The implementation uses the CBOR Object Signing and Encryption {{-COSE}}, maintained at:
- https://github.com/erdtman/cose-js

The implementation uses an implementation of {{-certificate-transparency-v2}},
maintained at:

- https://github.com/transmute-industries/rfc9162/tree/main/src/CoMETRE

## Contact

Orie Steele (orie@transmute.industries)
