import { LightningElement, track } from 'lwc';
import fetchProperties from '@salesforce/apex/PropertyController.fetchProperties';
import saveProperties from '@salesforce/apex/PropertyController.saveProperties';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PropertySearch extends LightningElement {
    @track searchTerm = '';
    @track propertyData = [];
    @track query = '';
    @track compStreet = '';
    @track compCity = '';
    @track compState = '';
    @track compZip = '';
    @track useYearBuilt = true;
    @track take = 10;
    @track skip = 0;
    mortgageData = [];

    handleInputChange(event) {
        const { name, value } = event.target;
        this[name] = value;
    }

    handleCheckboxChange(event) {
        this.useYearBuilt = event.target.checked;
    }

    columns = [
        { label: 'Street', fieldName: 'street' },
        { label: 'City', fieldName: 'city' },
        { label: 'State', fieldName: 'state' },
        { label: 'ZIP', fieldName: 'zip' , type: 'string'},
        { label: 'Bedrooms', fieldName: 'bedrooms', type: 'string' },
        { label: 'Bathrooms', fieldName: 'bathrooms', type: 'string' },
        { label: 'Year Built', fieldName: 'yearBuilt', type: 'string' },
        { label: 'Estimated Value', fieldName: 'estimatedValue', type: 'string' },
        { label: 'Latest Mortgage Amount', fieldName: 'latestMortgageAmount', type: 'string' },
        { label: 'Mortgage Lender', fieldName: 'latestMortgageLender' }
    ];

    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    async handleSearch() {
        try {
            const results = await fetchProperties({
                query: this.query,
                street: this.compStreet,
                city: this.compCity,
                state: this.compState,
                zip: this.compZip,
                useYearBuilt: this.useYearBuilt,
                skip: Number(this.skip),
                take: Number(this.take)
            });

            this.propertyData = results.map((prop, index) => {
                const address = prop.address || {};
                const building = prop.building || {};
                const valuation = prop.valuation || {};
                const latestMortgage = (prop.mortgageHistory && prop.mortgageHistory.length > 0)
                    ? prop.mortgageHistory.sort((a, b) => new Date(b.saleDate) - new Date(a.saleDate))[0]
                    : {};
                this.mortgageData = prop.mortgageHistory;
                return {
                    id: prop._id || index,
                    street: address.street || '',
                    city: address.city || '',
                    state: address.state || '',
                    zip: address.zip || '',
                    bedrooms: building.roomCount || 0,
                    bathrooms: building.bathroomCount || 0,
                    yearBuilt: building.yearBuilt || '',
                    estimatedValue: valuation.estimatedValue || 0,
                    latestMortgageAmount: latestMortgage.loanAmount || 0,
                    latestMortgageLender: latestMortgage.lenderName || 'N/A'
                };
            });

        } catch (error) {
            console.error('Error fetching data:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to fetch property data',
                    variant: 'error'
                })
            );
        }
    }

    async handleSave() {
        try {
            await saveProperties({ properties: this.propertyData, mortgages: this.mortgageData });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Properties saved to Salesforce successfully',
                    variant: 'success'
                })
            );
        } catch (error) {
            console.error('Save error:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Saving',
                    message: error?.body?.message || 'Failed to save records',
                    variant: 'error'
                })
            );
        }
    }
}
