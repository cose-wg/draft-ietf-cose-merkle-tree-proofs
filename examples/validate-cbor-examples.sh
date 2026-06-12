#!/usr/bin/env bash

set -euo pipefail

usage_diag='usage.cbor-diag'
inclusion_diag='receipt-of-inclusion.cbor-diag'
consistency_diag='receipt-of-consistency.cbor-diag'

usage() {
    echo "usage: $0 XML_PATH [--usage-diag FILE] [--inclusion-diag FILE] [--consistency-diag FILE]" >&2
    exit 1
}

xml_path=''

while [ "$#" -gt 0 ]; do
    case "$1" in
        --usage-diag)
            [ "$#" -ge 2 ] || usage
            usage_diag="$2"
            shift 2
            ;;
        --inclusion-diag)
            [ "$#" -ge 2 ] || usage
            inclusion_diag="$2"
            shift 2
            ;;
        --consistency-diag)
            [ "$#" -ge 2 ] || usage
            consistency_diag="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        -*)
            usage
            ;;
        *)
            if [ -n "$xml_path" ]; then
                usage
            fi
            xml_path="$1"
            shift
            ;;
    esac
done

[ -n "$xml_path" ] || usage
xml_path="$(realpath "$xml_path")"

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

cd "$workdir"
kramdown-rfc-extract-sourcecode -dchk "$xml_path"

# Handle inconsistent double definition and different start rule
cddlc -tcddl -2rTverifiable-proofs chk/cddl/*.cddl -SReceipt_For_Inclusion >chk/all-1.cddl
cddlc -tcddl -2rTverifiable-proofs chk/cddl/*.cddl -SReceipt_For_Consistency >chk/all-2.cddl
cddlc -tcddl -2rTverifiable-proofs chk/cddl/*.cddl -SSignature_With_Receipt >chk/all-3.cddl

process_diag() {
    if sed 's/\.\.\.//g' "$1" | edn-abnf -tcbor > "$2"; then
        cddl "$3" vp "$2" | diag2diag.rb -e
    else
        echo "*** Parse FAIL: $1"
    fi
    echo
}

process_diag "chk/cbor-diag/$inclusion_diag" chk/i1.cbor chk/all-1.cddl
process_diag "chk/cbor-diag/$consistency_diag" chk/c1.cbor chk/all-2.cddl
process_diag "chk/cbor-diag/$usage_diag" chk/s1.cbor chk/all-3.cddl
