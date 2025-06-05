import { LightningElement, api } from 'lwc';

export default class oppotunityChildComponent extends LightningElement {
    @api sharedData;

    handleInput(event) {
        const { name, value } = event.target;
        this.dispatchEvent(new CustomEvent('update', {
            detail: {
                section: 'opportunity',
                field: name,
                value
            },
            bubbles: true,
            composed: true
        }));
    }

    @api updateFromParent(newData) {
        this.sharedData = { ...newData };
    }
}
