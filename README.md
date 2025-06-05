# shared-state-databind-realtime-lwc


# Lightning Web Components: Shared State CRM System

This project demonstrates a real-time data sync system using Lightning Web Components (LWC). A shared JavaScript object (`formData`) acts as the single source of truth, keeping Account, Contact, and Opportunity fields in sync across components.

## Components

- **accountParent**: Parent component containing Account fields and shared logic
- **contactChild**: Displays Contact fields, syncs Email/Phone
- **opportunityChild**: Displays Opportunity fields, reads shared data
- **sharedDataService**: Holds central `formData` and publish/subscribe logic

## Key Features

- Real-time two-way data binding
- Centralized state management
- Apex-based record creation
- Auto-reset after save

## Save Process

The parent component triggers the creation of Account, Contact, and Opportunity records via an Apex class `RecordController`.

---

## Author

Your Name
