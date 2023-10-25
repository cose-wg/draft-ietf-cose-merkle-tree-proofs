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

## Algorithms Registry {#sec-verifiable-data-structure-algorithms}

This document establishes a registry of verifiable data structure algorithms,
with the following initial contents:

| Identifier            | Algorithm | Reference
|---
|0 | N/A                |
|1 | RFC9162_SHA256     | {{-certificate-transparency-v2}}
{: #verifiable-data-structure-values align="left" title="Verifiable Data Structure Alogrithms"}

### Registration Requirements

Each specification MUST define how to encode the algorithm and proof types in CBOR.

Each specification MUST define how to produce and consume the supported proof types.

See {{sec-rfc-9162-verifiable-data-structure-definition}} as an example.

# Proof Types in CBOR

Proof types are specific to their associated "verifiable data structure",
for example, different Merkle trees might support different representations of "inclusion proof" or "consistency proof".

Implementers should not expect interoperability accross "verifiable data structures",
but they should expect conceptually similar properties across registered proof types.

For example, 2 different merkle tree based verifiable data structures might both support proofs of inclusion.
Protocols requiring proof of inclusion ought to be able to preserve their functionality,
while switching from one verifiable data structure to another, so long as both structures support the same proof types.

## Proof Types Registry {#sec-verifiable-data-structure-proof-types}

This document establishes a registry of verifiable data structure proof types tags,
with the following initial contents:

| Identifier  | Proof Type   | Proof Value | Reference
|---
|0            | N/A          | N/A | N/A
|1            | inclusion    | array of bstr | {{sec-generic-inclusion-proof}}
|2            | consistency  | array of bstr | {{sec-generic-consistency-proof}}
{: #verifiable-data-structure-proof-types-values align="left" title="Verifiable Data Structure Proof Types"}

## Inclusion Proof {#sec-generic-inclusion-proof}

Inclusion proofs provide a mechanism for a verifier to validate set membership.

The integer identifier for this Proof Type is 1.
The string identifier for this Proof Type is "inclusion".
The value of this Proof Type is array of bstr.

{{sec-rfc9162-sha256-inclusion-proof}} provides a concrete example.

## Consistency Proof {#sec-generic-consistency-proof}

Consistency proofs provide a mechanism for a verifier to validate the consistency of a verifiable data structure.

The integer identifier for this Proof Type is 2.
The string identifier for this Proof Type is "consistency".
The value of this Proof Type is array of bstr.

{{sec-rfc9162-sha256-consistency-proof}} provides a concrete example.

# RFC9162_SHA256 as a Verifiable Data Structure {#sec-rfc-9162-verifiable-data-structure-definition}

This section defines how the data structures described in {{-certificate-transparency-v2}}
are mapped to the terminology defined in this document, using cbor and cose.

RFC9162_SHA256 requires the following:

- -11111 (verifiable-data-structure): 1, the integer representing the RFC9162_SHA256 verifiable data structure algorithm.
- -22222 (verifiable-data-proofs): a map supporting the following proof types:
- 1 (inclusion-proof): an array of bstr representing RFC9162_SHA256 inclusion proofs
- 2 (consistency-proof): an array of bstr representing RFC9162_SHA256 consistency proofs

## Algorithm Definition

The integer identifier for this Verifiable Data Structure is 1.
The string identifier for this Verifiable Data Structure is "RFC9162_SHA256".

See {{sec-verifiable-data-structure-algorithms}}.

See {{-certificate-transparency-v2}}, 2.1.1. Definition of the Merkle Tree,
for a complete description of this verifiable data structure.

## Inclusion Proof Definition {#sec-rfc9162-sha256-inclusion-proof}

See {{-certificate-transparency-v2}}, 2.1.3.1. Generating an Inclusion Proof,
for a complete description of this verifiable data structure proof type.

The cbor representation of an inclusion proof for RFC9162_SHA256 is:

~~~~ cddl
inclusion-proof = [
    tree-size: int
    leaf-index: int
    inclusion-path: [+ bstr]
]
~~~~

### Inclusion Proof Signature

In a signed inclusion proof, the previous merkle tree root, maps to tree-size-1, and is a detached payload.

Other specifications refer to signed inclusion proofs as "receipts",
profiles of proof signatures are encouraged to make additional protected header parameters mandatory.

TODO: reference to scitt receipts.

The protected header for an RFC9162_SHA256 inclusion proof signature is:

* alg (label: 1): REQUIRED. Signature algorithm identifier. Value type: int / tstr.
* verifiable-data-structure (label: -11111): REQUIRED. verifiable data structure algorithm identifier. Value type: int / tstr.

The unprotected header for an RFC9162_SHA256 inclusion proof signature is:

~~~~ cddl

inclusion-proofs = [ + bstr ]

verifiable-proofs = {
  &(inclusion-proof: 1) => inclusion-proofs
}

unprotected-header-map = {
  &(verifiable-data-proof: -22222) => verifiable-proofs
  * cose-label => cose-value
}
~~~~

* inclusion-proof (label: 1): REQUIRED. proof type identifier. Value type: [ + bstr ].

The payload of an RFC9162_SHA256 inclusion proof signature is the previous Merkle tree hash as defined in {{-certificate-transparency-v2}}.

The payload MUST be detached.

Detaching the payload forces verifiers to recompute the root from the inclusion proof signature,
this protects against implementation errors where the signature is verified but the root does not match the inclusion proof.

~~~~ cbor-diag
18(                                 / COSE Single Signer Data Object        /
    [
      h'a3012604...392b6601',       / Protected header                      /
      {                             / Unprotected header                    /
        -22222: {                   / Proofs                                /
          1: [                      / Inclusion proofs (1)                  /
            h'83040282...1f487bb1', / Inclusion proof 1                     /
          ]
        },
      },
      h'',                          / Detached payload                      /
      h'1c0f970e...bf4bae7f'        / Signature                             /
    ]
)
~~~~

~~~~ cbor-diag
{                                   / Protected header                      /
  1: -7,                            / Cryptographic algorithm to use        /
  4: h'68747470...6d706c65',        / Key identifier                        /
  -11111: 1                         / Verifiable data structure             /
}
~~~~

~~~~ cbor-diag
[                                   / Inclusion proof 1                     /
  4,                                / Tree size                             /
  2,                                / Leaf index                            /
  [                                 / Inclusion hashes (2)                  /
     h'a39655d4...d29a968a'         / Intermediate hash 1                   /
     h'57187dff...1f487bb1'         / Intermediate hash 2                   /
  ]
]
~~~~

## Consistency Proof Definition {#sec-rfc9162-sha256-consistency-proof}

See {{-certificate-transparency-v2}}, 2.1.4.1. Generating a Consistency Proof,
for a complete description of this verifiable data structure proof type.

The cbor representation of a consistency proof for RFC9162_SHA256 is:

~~~~ cddl
consistency-proof = [
    tree-size-1: int ; size of the tree, when the previous root was produced.
    tree-size-2: int ; size of the tree, when the latest root was produced.
    consistency-path: [+ bstr] ; consistency path, from previous root to latest root.
]
~~~~

Editors note: tree-size-1, could be ommited, if an inclusion-proof is always present, since the inclusion proof contains, tree-size-1.

### Consistency Proof Signature

In a signed consistency proof, the latest merkle tree root, maps to tree-size-2, and is an attached payload.

The protected header for an RFC9162_SHA256 consistency proof signature is:

* alg (label: 1): REQUIRED. Signature algorithm identifier. Value type: int / tstr.
* verifiable-data-structure (label: TBD_1): REQUIRED. verifiable data structure algorithm identifier. Value type: int / tstr.
* kid (label: 4): OPTIONAL. Key identifier. Value type: bstr
* crit (label: 2): OPTIONAL. Criticality marker. Value type: [ + label ]

The unprotected header for an RFC9162_SHA256 consistency proof signature is:

~~~~ cddl

consistency-proofs = [ + bstr ]

verifiable-proofs = {
  &(consistency-proof: 2) => consistency-proofs
}

unprotected-header-map = {
  &(verifiable-data-proof: -22222) => verifiable-proofs
  * cose-label => cose-value
}
~~~~

* consistency-proof (label: 2): REQUIRED. proof type identifier. Value type:  [ + bstr ].

The payload of an RFC9162_SHA256 consistency proof signature is:

The latest Merkle tree hash as defined in {{-certificate-transparency-v2}}.

The payload MUST be attached.

~~~~ cbor-diag
18(                                 / COSE Single Signer Data Object        /
    [
      h'a3012604...392b6601',       / Protected header                      /
      {                             / Unprotected header                    /
        -22222: {                   / Proofs                                /
          2: [                      / Consistency proofs (1)                /
            h'83040682...2e73a8ab', / Consistency proof 1                   /
          ]
        },
      },
      h'430b6fd7...f74c7fc4',       / Payload                               /
      h'8bcb1b79...78829bca'        / Signature                             /
    ]
)
~~~~

~~~~ cbor-diag
{                                   / Protected header                      /
  1: -7,                            / Cryptographic algorithm to use        /
  4: h'68747470...6d706c65',        / Key identifier                        /
  -11111: 1                         / Verifiable data structure             /
}
~~~~

~~~~ cbor-diag
[                                   / Consistency proof 1                   /
  4,                                / Tree size 1                           /
  6,                                / Tree size 2                           /
  [                                 / Consistency hashes (2)                /
     h'0bdaaed3...32568964'         / Intermediate hash 1                   /
     h'75f177fd...2e73a8ab'         / Intermediate hash 2                   /
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
* Label: -11111
* Value type: int / tstr
* Value registry: https://www.iana.org/assignments/cose/cose.xhtml#header-parameters
* Description: Algorithm name for verifiable data structure, used to produce verifiable data proofs.

* Name: verifiable-data-proof
* Label: -222222
* Value type: int / tstr
* Value registry: https://www.iana.org/assignments/cose/cose.xhtml#header-parameters
* Description: Location for verifiable data proofs in COSE Header Parameters.

### Verifiable Data Structures {#verifiable-data-structure-registry}

IANA will be asked to establish a registry of tree algorithm identifiers,
named "Verifiable Data Structures" to be administered under a Specification Required policy {{-iana-considerations-guide}}.

Template:

* Identifier: The two-byte identifier for the algorithm
* Algorithm: The name of the data structure
* Reference: Where the data structure is defined

Initial contents: Provided in {{verifiable-data-structure-values}}

### Verifiable Data Structure Proof Types {#verifiable-data-structure-proof-types-registry}

IANA will be asked to establish a registry of tree algorithm identifiers,
named "Verifiable Data Structures Proof Types" to be administered under a Specification Required policy {{-iana-considerations-guide}}.

Template:

* Identifier: The two-byte identifier for the algorithm
* Algorithm: The name of the proof type algorithm
* Reference: Where the algorithm is defined

Initial contents: Provided in {{verifiable-data-structure-proof-types-values}}

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

The current version ('main') implements the tree algorithm, inclusion proof and consistency proof concepts of this draft.

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
