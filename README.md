# Canadian Healthcare RDBMS

### A relational database model for a unified Canadian electronic medical record system

---

## Overview

This project models a **centralized relational database** designed to standardize and streamline **electronic medical record (EMR)** management across Canada. Despite the country’s universal healthcare system, record accessibility and interoperability remain significant challenges. This database aims to address those issues by enabling physicians, pharmacists, and other healthcare professionals to securely share and update patient records across provinces.

The model was implemented in **SQL Server** and follows **BCNF normalization**, featuring entity specialization/generalization, triggers for audit history, and optimized indexing for frequent healthcare queries.

---

## Database Design

The database comprises several key entities and relationships designed to reflect real-world healthcare interactions:

| Entity | Description |
|---------|-------------|
| **Patient** | Stores demographic data, health card number, general notes, family history, and prescriptions. |
| **Physician** | Represents healthcare providers with unique IDs, specialties (e.g., GP, Internist, Pediatrician), and province of practice. |
| **Pharmacy** | Tracks pharmacies across provinces where patients can refill prescriptions. |
| **DocVisit** | Logs physician visits, connecting patients to doctors with visit notes and timestamps. |
| **PharmVisit** | Records pharmacy visits and prescription refills. |
| **Prescriptions & RXLink** | Models prescriptions and the many-to-many relationships between patients and medications. |
| **Provinces** | Lists all Canadian provinces and territories to normalize location data. |
| **PatientHistory** | Automatically tracks changes to patient notes via triggers for auditability. |

---

## Technical Features

- **Normalization:** All tables satisfy **BCNF**, eliminating redundancy in province and prescription data.  
- **Triggers:** The `PatientHistoryTrigger` automatically logs updates to patient notes for historical traceability.  
- **Indexes:** Added to optimize common queries by specialty, province, and visit date.  
- **Subtype Entities:** Models specialization/generalization relationships such as:
  - `Physician` → `GP`, `Internist`, `Pediatrician`
  - `Patient` → `Male`, `Female`, `Intersex`
- **Mock Data:** Populated using **Mockaroo** for realistic test scenarios across all provinces.

---

## Schema Highlights

- **Total Entities**: 17
- **Relationships**: Fully defined with foreign keys and referential integrity constraints.
- **Audit Logging**: Implemented via history table and triggers.
- **Index Coverage**: 13+ indexes to enhance search and join performance.

---

## Future Work

- Extend physician specialization to cover all Canadian medical subfields.
- Add role-based access control (RBAC) for privacy and compliance.
- Integrate FHIR (Fast Healthcare Interoperability Resources) compatibility for real-world interoperability.
- Design and implement a secure web client for healthcare professionals.

---

## Author

**Sachin Mohandas**

Boston University – MET CS 669: Database Design and Implementation

Project Iteration 5 (December 2023)
