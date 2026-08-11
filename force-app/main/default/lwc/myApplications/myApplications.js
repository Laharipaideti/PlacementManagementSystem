import {
    LightningElement,
    api,
    wire
} from 'lwc';

import getMyApplications
    from '@salesforce/apex/ApplicationController.getMyApplications';

import {
    refreshApex
} from '@salesforce/apex';


export default class MyApplications extends LightningElement {

    @api recordId;

    applications = [];

    errorMessage = '';

    isLoading = true;

    wiredApplicationsResult;


    @wire(getMyApplications, {
        studentId: '$recordId'
    })
    wiredApplications(result) {

        this.wiredApplicationsResult = result;

        const {
            data,
            error
        } = result;

        this.isLoading = false;

        if (data) {

            this.applications = data;

            this.errorMessage = '';

        } else if (error) {

            this.applications = [];

            this.errorMessage =
                this.getErrorMessage(error);
        }
    }


    @api
    async refreshApplications() {

        if (this.wiredApplicationsResult) {

            return refreshApex(
                this.wiredApplicationsResult
            );
        }

        return null;
    }


    get showApplications() {

        return (
            !this.isLoading &&
            !this.errorMessage &&
            this.applications.length > 0
        );
    }


    get showEmpty() {

        return (
            !this.isLoading &&
            !this.errorMessage &&
            this.applications.length === 0
        );
    }


    getErrorMessage(error) {

        if (
            error &&
            error.body &&
            error.body.message
        ) {

            return error.body.message;
        }

        if (
            error &&
            error.message
        ) {

            return error.message;
        }

        return 'Unable to load applications.';
    }
}