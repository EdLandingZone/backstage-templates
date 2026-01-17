# Backstage Templates

This repository contains Backstage scaffolder templates for infrastructure provisioning.

## Available Templates

| Template | Description |
|----------|-------------|
| [mongodb-terraform](./mongodb-terraform/) | MongoDB Backstage Example |

## Usage

These templates are consumed by Backstage via the catalog. They are registered in Backstage's `app-config.yaml`:

```yaml
catalog:
  locations:
    - type: url
      target: https://github.com/your-github-org/backstage-templates/blob/main/catalog-info.yaml
      rules:
        - allow: [Location, Template]
```

## Template Structure

Each template follows this structure:

```
template-name/
├── template.yaml          # Backstage template definition
└── skeleton/              # Files to scaffold
    ├── catalog-info.yaml  # Registers created resource in Backstage
    ├── README.md
    └── ...
```

## Adding New Templates

1. Create a new directory under the root
2. Add `template.yaml` with the scaffolder definition
3. Add `skeleton/` directory with template files
4. Register the template in `catalog-info.yaml`
5. Open a PR for review

## Testing

Templates are validated on PR via GitHub Actions:
- YAML syntax validation
- Terraform skeleton validation (`terraform validate`)

## Local Development

To test templates locally with Backstage:

1. Clone this repo
2. Mount in your Backstage docker-compose:
   ```yaml
   volumes:
     - ./path/to/backstage-templates:/app/templates:ro
   ```
3. Reference in app-config.yaml:
   ```yaml
   catalog:
     locations:
       - type: file
         target: /app/templates/catalog-info.yaml
   ```
