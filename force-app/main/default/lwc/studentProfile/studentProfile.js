import { LightningElement, api, wire } from 'lwc';

import { getRecord } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import STUDENT_NAME from '@salesforce/schema/student__c.Name';
import STUDENT_EMAIL from '@salesforce/schema/student__c.Email__c';
import STUDENT_PHONE from '@salesforce/schema/student__c.Phone__c';
import STUDENT_BRANCH from '@salesforce/schema/student__c.Branch__c';
import STUDENT_CGPA from '@salesforce/schema/student__c.CGPA__c';
import STUDENT_SKILLS from '@salesforce/schema/student__c.Skills__c';
import STUDENT_LOCATION from '@salesforce/schema/student__c.Preferred_Location__c';

const FIELDS = [
    STUDENT_NAME,
    STUDENT_EMAIL,
    STUDENT_PHONE,
    STUDENT_BRANCH,
    STUDENT_CGPA,
    STUDENT_SKILLS,
    STUDENT_LOCATION
];

export default class StudentProfile extends LightningElement {

    @api recordId;


    studentName = '';
    email = '';
    phone = '';
    branch = '';
    cgpa = '';
    skills = '';
    preferredLocation = '';


    // ==========================================
    // GET STUDENT RECORD
    // ==========================================

    @wire(getRecord, {
        recordId: '$recordId',
        fields: FIELDS
    })
    wiredStudent({ data, error }) {

        if (data) {

            this.studentName =
                data.fields.Name?.value || '';

            this.email =
                data.fields.Email__c?.value || '';

            this.phone =
                data.fields.Phone__c?.value || '';

            this.branch =
                data.fields.Branch__c?.value || '';

            this.cgpa =
                data.fields.CGPA__c?.value ?? '';

            this.skills =
                data.fields.Skills__c?.value || '';

            this.preferredLocation =
                data.fields.Preferred_Location__c?.value || '';

        }

        else if (error) {

            console.error(
                'Error loading student:',
                error
            );

        }
    }


    // ==========================================
    // BRANCH OPTIONS
    // ==========================================

    get branchOptions() {

        return [

            {
                label: '--None--',
                value: ''
            },

            {
                label: 'CSE',
                value: 'CSE'
            },

            {
                label: 'IT',
                value: 'IT'
            },

            {
                label: 'CSBS',
                value: 'CSBS'
            },

            {
                label: 'AIDS',
                value: 'AIDS'
            },

            {
                label: 'AIML',
                value: 'AIML'
            },

            {
                label: 'ECE',
                value: 'ECE'
            },

            {
                label: 'EEE',
                value: 'EEE'
            },

            {
                label: 'MECH',
                value: 'MECH'
            }

        ];
    }


    // ==========================================
    // LOCATION OPTIONS
    // ==========================================

    get locationOptions() {

        return [

            {
                label: '--None--',
                value: ''
            },

            {
                label: 'Hyderabad',
                value: 'Hyderabad'
            },

            {
                label: 'Bengaluru',
                value: 'Bengaluru'
            },

            {
                label: 'Chennai',
                value: 'Chennai'
            },

            {
                label: 'Pune',
                value: 'Pune'
            },

            {
                label: 'Mumbai',
                value: 'Mumbai'
            },

            {
                label: 'Delhi',
                value: 'Delhi'
            },

            {
                label: 'Remote',
                value: 'Remote'
            }

        ];
    }


    // ==========================================
    // INPUT HANDLERS
    // ==========================================

    handleNameChange(event) {

        this.studentName =
            event.target.value;
    }


    handleEmailChange(event) {

        this.email =
            event.target.value;
    }


    handlePhoneChange(event) {

        this.phone =
            event.target.value;
    }


    handleBranchChange(event) {

        this.branch =
            event.detail.value;
    }


    handleCgpaChange(event) {

        this.cgpa =
            event.target.value;
    }


    handleSkillsChange(event) {

        this.skills =
            event.target.value;
    }


    handleLocationChange(event) {

        this.preferredLocation =
            event.detail.value;
    }


    // ==========================================
    // SUBMIT
    // ==========================================

    handleSubmit(event) {

        event.preventDefault();

        const fields = {};

        fields.Name =
            this.studentName;

        fields.Email__c =
            this.email;

        fields.Phone__c =
            this.phone;

        fields.Branch__c =
            this.branch;

        fields.CGPA__c =
            this.cgpa;

        fields.Skills__c =
            this.skills;

        fields.Preferred_Location__c =
            this.preferredLocation;


        const form =
            this.template.querySelector(
                'lightning-record-edit-form'
            );


        form.submit(fields);
    }


    // ==========================================
    // SUCCESS
    // ==========================================

    handleSuccess(event) {

        console.log(
            'Student profile saved:',
            event.detail.id
        );


        this.showToast(
            'Success',
            'Student profile saved successfully.',
            'success'
        );


        this.dispatchEvent(
            new CustomEvent(
                'profilesaved',
                {
                    detail: {
                        studentId:
                            event.detail.id
                    },
                    bubbles: true,
                    composed: true
                }
            )
        );
    }


    // ==========================================
    // ERROR
    // ==========================================

    handleError(event) {

        console.error(
            'Student profile save failed:',
            event.detail
        );


        let message =
            'Unable to save student profile.';


        if (
            event.detail &&
            event.detail.detail
        ) {

            message =
                event.detail.detail;
        }


        this.showToast(
            'Error',
            message,
            'error'
        );
    }


    // ==========================================
    // TOAST
    // ==========================================

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