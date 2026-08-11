import { LightningElement, api } from 'lwc';

export default class EmptyState extends LightningElement {

    @api title = 'No Records';

    @api message = 'No records are currently available.';

    @api actionLabel;

    get showAction() {

        return !!this.actionLabel;
    }

    handleAction() {

        this.dispatchEvent(
            new CustomEvent('action')
        );
    }
}