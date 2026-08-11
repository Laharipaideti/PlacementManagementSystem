import {
    LightningElement,
    api,
    wire
} from 'lwc';

import getEligibleJobs
    from '@salesforce/apex/ApplicationController.getEligibleJobs';

import submitApplication
    from '@salesforce/apex/ApplicationController.submitApplication';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import {
    refreshApex
} from '@salesforce/apex';


export default class EligibleJobs extends LightningElement {

    @api recordId;

    jobs = [];

    errorMessage = '';

    successMessage = '';

    isLoading = true;

    applyingJobId = null;

    selectedJob = null;

    wiredJobsResult;


    @wire(getEligibleJobs, {
        studentId: '$recordId'
    })
    wiredJobs(result) {

        this.wiredJobsResult = result;

        const {
            data,
            error
        } = result;

        this.isLoading = false;

        if (data) {

            this.jobs = data;

            this.errorMessage = '';

        } else if (error) {

            this.jobs = [];

            this.errorMessage =
                this.getErrorMessage(error);
        }
    }


    /*
     * Parent can call this method
     * after Student Profile is saved.
     */
    @api
    async refreshJobs() {

        if (this.wiredJobsResult) {

            return refreshApex(
                this.wiredJobsResult
            );
        }

        return null;
    }


    get showJobs() {

        return (
            !this.isLoading &&
            !this.errorMessage &&
            this.jobs.length > 0
        );
    }


    get showEmpty() {

        return (
            !this.isLoading &&
            !this.errorMessage &&
            this.jobs.length === 0
        );
    }


    get isApplying() {

        return this.applyingJobId !== null;
    }


    handleViewDetails(event) {

        const jobId =
            event.detail.jobId;

        this.selectedJob =
            this.jobs.find(
                job => job.Id === jobId
            );
    }


    async handleApply(event) {

        const jobId =
            event.detail.jobId;

        if (this.applyingJobId) {

            return;
        }

        this.applyingJobId = jobId;

        this.errorMessage = '';

        this.successMessage = '';


        try {

            const applicationId =
                await submitApplication({
                    studentId: this.recordId,
                    jobId: jobId
                });


            console.log(
                'Application created:',
                applicationId
            );


            this.successMessage =
                'Application submitted successfully.';


            this.showToast(
                'Success',
                'Application submitted successfully.',
                'success'
            );


            /*
             * Tell parent that application
             * was successfully created.
             */
            this.dispatchEvent(
                new CustomEvent(
                    'applicationsaved',
                    {
                        detail: {
                            applicationId:
                                applicationId
                        }
                    }
                )
            );


            await this.refreshJobs();

        } catch (error) {

            this.errorMessage =
                this.getErrorMessage(error);


            this.showToast(
                'Application Failed',
                this.errorMessage,
                'error'
            );

        } finally {

            this.applyingJobId = null;
        }
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

        return (
            'Something went wrong. Please try again.'
        );
    }


    showToast(
        title,
        message,
        variant
    ) {

        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}