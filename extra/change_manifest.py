from copy import deepcopy
from pathlib import Path
from dbt.contracts.graph.manifest import WritableManifest
from dbt.contracts.results import CatalogArtifact
import json


packages_to_keep =['frosty']
elements_to_scan = ['nodes','sources','macros']
directory = Path.cwd()
input_manifest_file  = directory / "manifest.json"
output_directory = Path.cwd() / "output"
Path(output_directory).mkdir(parents=True, exist_ok=True)

def edit_catalog(
    catalog: CatalogArtifact, manifest: WritableManifest
) -> CatalogArtifact:
    output = deepcopy(catalog)
    node_names = tuple(node for node in output.nodes)
    for node in node_names:
        if node not in manifest.nodes:
            output.nodes.pop(node)
    source_names = tuple(source for source in output.sources)
    for source in source_names:
        if source not in manifest.sources:
            output.sources.pop(source)
    return output

with open(input_manifest_file, 'r') as f:
    manifest_json = json.load(f)

output = deepcopy(manifest_json)
for element in elements_to_scan:
    node_names = [node for node in output[element].keys()]
    to_keep = {}
    for node_name in node_names:
        try:
            if output[element][node_name]['package_name'] in packages_to_keep:
                to_keep[node_name] = output[element][node_name]
        except:
            print(f'package_name not found in {node_name} and {element}')
            input('waiting')
    output[element] = to_keep
output_manifest_file = output_directory / 'manifest.json'
with open(output_manifest_file, 'w') as f:
    json.dump(output, f )

manifest = WritableManifest.read(output_manifest_file.as_posix())
input_catalog_file = directory / "catalog.json"
catalog = CatalogArtifact.read(input_catalog_file.as_posix())
catalog = edit_catalog(catalog, manifest)
output_catalog_file = output_directory / "catalog.json"
catalog.write(output_catalog_file.as_posix())