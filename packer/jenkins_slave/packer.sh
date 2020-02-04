VERSION=$(
python3 -c 'import json; output=json.load(open("vars.json", "r")); print(output["version"])';
)

packer build -var-file vars.json ami.json | tee "./logs/build-${VERSION}.log"