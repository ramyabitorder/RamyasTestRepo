import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import accList from '@salesforce/apex/AccountList.accList';
const COLUMNS =[
    {label:'Name', fieldName:'Name', cellAttributes:{
        class:'cellcolor'
    }},
    {label:'Id', fieldName:'Id',cellAttributes:{
        class:'cellcolor'
    }},
    {label:'Need Contact', fieldName:'Need_Contact__c',cellAttributes:{
        class:'cellcolor'
    }}
    ]
export default class AccountList extends LightningElement {
    columns = COLUMNS;
    isCreateAccount = false;
    accounts;
    wiredacc;
    @wire(accList)
wiredCallback(result) {
    this.wiredacc = result;
    if (result.data) {
        this.accounts = result.data;
        console.log(this.accounts);
    } else if (result.error) {
        console.log(result.error);
    }
}
handleSuccess() {
    const evt = new ShowToastEvent({
        title: 'Record Created',
        message: 'An Account and a Contact Has Been Created',
        variant: 'success',
    });
    this.dispatchEvent(evt);
    this.isCreateAccount=false;
    this.wiredacc = refreshApex(this.wiredacc);
}
NewAccount(){
    this.isCreateAccount = true;
}
closePopup(){
    this.isCreateAccount = false;
}
}