import { LightningElement, track } from 'lwc';
import saveFormData from '@salesforce/apex/FormDataController.saveFormData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class accountParentComponent extends LightningElement {
    @track formData = {
        account: { name: '', industry: '', rating: '', email: '', phone: '' },
        contact: { email: '', phone: '', firstName: '', lastName: '' },
        opportunity: { name: '', stageName: '', amount: '' }
    };
    
    handleChildUpdate(event) {
        const { section, field, value } = event.detail;
        this.formData = {
            ...this.formData,
            [section]: { ...this.formData[section], [field]: value }
        };
        if(this.formData.contact.phone != this.formData.account.phone){
            this.formData.account.phone = this.formData.contact.phone;
        }
        if(this.formData.contact.email != this.formData.account.email){
            this.formData.account.email = this.formData.contact.email;
        }
        
        // Push updates to children
        this.template.querySelector('c-contact-child-component')?.updateFromParent(this.formData);
        this.template.querySelector('c-oppotunity-child-component')?.updateFromParent(this.formData);
    }

    handleInput(event) {
        const field = event.target.name;
        const value = event.target.value;
        this.formData.account[field] = value;

        // Sync down
        this.template.querySelector('c-contact-child-component')?.updateFromParent(this.formData);
        this.template.querySelector('c-oppotunity-child-component')?.updateFromParent(this.formData);
    }

    async handleSave() {
        try {
            await saveFormData({ jsonData: JSON.stringify(this.formData) });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record saved successfully!',
                    variant: 'success'
                })
            );            
            this.resetForm();
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong. Please Contact Admin!',
                    variant: 'error'
                })
            );            
            console.error('Save failed:', error);
        }
    }

    resetForm() {
        this.formData = {
            account: { name: '', industry: '', rating: '', email: '', phone: '' },
            contact: { email: '', phone: '', firstName: '', lastName: '' },
            opportunity: { name: '', stageName: '', amount: '' }
        };

        // Force refresh
        this.template.querySelector('c-contact-child-component')?.updateFromParent(this.formData);
        this.template.querySelector('c-oppotunity-child-component')?.updateFromParent(this.formData);
    }
}