import { LightningElement, api } from 'lwc';

export default class contactChildComponent extends LightningElement {
    @api sharedData;

    handleInput(event) {
        const { name, value } = event.target;
        this.dispatchEvent(new CustomEvent('update', {
            detail: {
                section: 'contact',
                field: name,
                value
            },
            bubbles: true,
            composed: true
        }));
    }

    @api updateFromParent(newData) {
        this.sharedData = { ...newData };
        if(this.sharedData.contact.phone != this.sharedData.account.phone){
            this.sharedData.contact.phone = this.sharedData.account.phone;
        }
        if(this.sharedData.contact.email != this.sharedData.account.email){
            this.sharedData.contact.email = this.sharedData.account.email;
        }
    }
}