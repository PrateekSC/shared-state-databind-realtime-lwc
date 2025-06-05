# shared-state-databind-realtime-lwc


# 🔄 LWC Real-Time Data Sync System (Account, Contact, Opportunity)

This Salesforce LWC project demonstrates **real-time data synchronization** across components using a shared JavaScript object (`formData`). It enables seamless two-way data binding between a **parent Account component** and its **Contact** and **Opportunity** child components.

---

## 📦 Project Overview

- 🧩 **Parent Component**: Manages 5 Account fields (e.g., Name, Industry, Rating, Email, Phone).
- 👨‍💼 **Contact Component**: Displays and updates standard Contact fields (must include Email, Phone).
- 💼 **Opportunity Component**: Displays standard Opportunity fields and stays in sync with shared data.

---

## 🔧 Features

- 🧠 **Single Source of Truth**: All component data is managed through one central JavaScript object: `formData`.
- 🔄 **Two-Way Binding**:
  - Updates in parent component reflect in both children instantly.
  - Updates in Contact component propagate back to parent and Opportunity.
- 🧬 **Shared State Management**:
  - Updates to any part of the shared `formData` trigger reactivity across the system.
- 💾 **Save Operation**:
  - On clicking **Save** in the parent, the full `formData` object is sent to Apex to create Account, Contact, and Opportunity records.
  - After saving, the UI resets and all fields are cleared.

---

## 🗂️ Component Breakdown

### 🔹 `accountParent`
- Fields: `Name`, `Industry`, `Rating`, `Email`, `Phone`
- Handles centralized `formData`
- Dispatches updates to child components
- Initiates save via Apex

### 🔹 `contactChild`
- Receives form data (Contact-related fields)
- Displays and updates `Email`, `Phone`, and other Contact fields
- Emits changes to parent

### 🔹 `opportunityChild`
- Receives Opportunity-related fields from `formData`
- Reflects latest updates to shared fields like `Email` and `Phone`

---

## 📄 Data Flow Architecture

```plaintext
contactChild   ⇄   accountParent   ⇄   opportunityChild
        ↑                 ↓
    shared formData object
