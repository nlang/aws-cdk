#!/bin/bash
set -euo pipefail
scriptdir=$(cd $(dirname $0) && pwd)
source ${scriptdir}/common.bash
# ----------------------------------------------------------

setup

# create directory in /tmp
outputs_folder=${integ_test_dir}/outputs
mkdir -p ${outputs_folder}

# set up outputs
outputs_file=${outputs_folder}/outputs.json
expected_file=${outputs_folder}/expected.json
touch $expected_file

# add prefixes as stacks are keyed on their stack name in the outputs file
expected_outputs=${scriptdir}/cdk-deploy-with-outputs-expected.template
sed "s|%STACK_NAME_PREFIX%|$STACK_NAME_PREFIX|g" "$expected_outputs" > "$expected_file"

cdk deploy ${STACK_NAME_PREFIX}-outputs-test-1 --outputs-file ${outputs_file}
echo "Stack deployed successfully"

# verify generated outputs file
generated_outputs_file="$(cat ${outputs_file})"
expected_outputs_file="$(cat ${expected_file})"
if [[ "${generated_outputs_file}" != "${expected_outputs_file}" ]]; then
    fail "unexpected outputs. Expected: ${expected_outputs_file} Actual: ${generated_outputs_file}"
fi 

# destroy
rm -rf ${outputs_folder}
cdk destroy -f ${STACK_NAME_PREFIX}-outputs-test-1

echo "✅  success"
