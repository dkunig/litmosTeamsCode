import { LightningElement,api, track, wire } from 'lwc';
import getAdmins from '@salesforce/apex/litmosTeamsController.getAdmins';
import getLeaders from '@salesforce/apex/litmosTeamsController.getLeaders';

export default class TeamAdminsAndLeaders extends LightningElement {
    @api recordId;
    @track admins;
    @track leaders;
    @track adminError;
    @track leaderError;
    connectedCallback() {
        console.log('connected callback');
        getAdmins({recordID:this.recordId})
        .then(result => {
            console.log('result: ' + result);
            this.admins = result;
            console.log('admins: ' + this.admins);
        })
        .catch(error => {
            this.adminError = error;
            console.log(this.adminError);
            this.admins = undefined;
        })
        getLeaders({recordID:this.recordId})
        .then(result => {
            console.log('leaders: ' + result);
            this.leaders = result;
        })
        .catch(error => {
            this.leaderError = error;
            console.log(this.leaderError);
            this.leaders = undefined;
        })
    }
    
}