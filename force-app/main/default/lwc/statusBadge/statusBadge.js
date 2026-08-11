import { LightningElement, api } from 'lwc';

export default class StatusBadge extends LightningElement {

    @api status;

    get badgeClass() {

        switch (this.status) {

            case 'Selected':
                return 'slds-badge slds-theme_success';

            case 'Rejected':
                return 'slds-badge slds-theme_error';

            case 'Interview Scheduled':
                return 'slds-badge slds-theme_warning';

            case 'Shortlisted':
                return 'slds-badge slds-theme_info';

            case 'Applied':
                return 'slds-badge';

            default:
                return 'slds-badge';
        }
    }
}