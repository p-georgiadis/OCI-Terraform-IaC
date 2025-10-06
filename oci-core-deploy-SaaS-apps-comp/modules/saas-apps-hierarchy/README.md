# SaaS Apps Hierarchy Module

## Purpose
Generic module for creating OCI compartment hierarchies with flexible nesting support.

## Features
- Supports 3-level compartment hierarchy (root, child, grandchild)
- Flexible compartment structure via nested maps
- Automatic freeform tagging
- IAM propagation delay management
- Enable/disable delete protection

## Scope
This module focuses solely on compartment creation. It does NOT include:
- IAM policies (managed separately)
- Quotas (managed separately)
- Tag namespaces (managed separately)

This separation follows infrastructure-as-code best practices by maintaining single responsibility.

## Usage
This is an internal module called by the parent module. See parent module documentation for usage.

## Variables
- `tenancy_ocid` - Root tenancy OCID for compartment creation
- `compartment_hierarchy` - Nested map defining the compartment structure

## Outputs
- `compartment_ids` - Map of compartment names to OCIDs