import LightningDatatable from "lightning/datatable";
import nameBadge from './nameBadge.html';
import logoType from './logoType.html';
import customPicklistTemplate from './customPicklist.html';
import customPicklistEditTemplate from './customPicklistEdit.html';

export default class CustomDataTableTypes extends LightningDatatable
{
    static customTypes = {
        nameBadge : {
            template: nameBadge,
            standardCellLayout: true,
            typeAttributes : ["name"]
        },
        logoType : {
            template: logoType,
            standardCellLayout: true,
            typeAttributes : ["logoUrl"]
        },
        customPicklist : {
            template: customPicklistTemplate,
            editTemplate : customPicklistEditTemplate,
            standardCellLayout: true,
            typeAttributes : ["options","value","context"]
        }
    }
}