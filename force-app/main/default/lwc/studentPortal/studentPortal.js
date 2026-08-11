import {
    LightningElement,
    api
} from 'lwc';


export default class StudentPortal
    extends LightningElement {

    @api recordId;


    async handleProfileSaved() {

        const eligibleJobs =
            this.template.querySelector(
                'c-eligible-jobs'
            );


        if (eligibleJobs) {

            await eligibleJobs.refreshJobs();
        }
    }


    async handleApplicationSaved() {

        const applications =
            this.template.querySelector(
                'c-my-applications'
            );


        if (applications) {

            await applications.refreshApplications();
        }
    }
}