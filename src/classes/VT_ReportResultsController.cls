/**********************************************************************************
* @author       Aaron Dominguez - aaron@nube53.com
* @date         20 October 2016
* @description  Controoler for ReportResults visualforce component
* @Revision     [AD] - 20/10/2016 - Initial version.
**********************************************************************************/
public with sharing class VT_ReportResultsController {

	//-- VARIABLES
	public Id theReportId {get; set;}
	public Boolean reportExecuted {get; set;}
    public transient VT_ReportResultsHelper.reportResponse reportResults {get; set;}

	//-- CONTROLLER
    public VT_ReportResultsController() {
        this.reportResults = new VT_ReportResultsHelper.reportResponse();
        this.reportExecuted = false;
    }

    //-- PAGE ACTIONS
    public PageReference runReport() {
        if (this.reportResults == null)          
            this.reportResults = new VT_ReportResultsHelper.reportResponse();
        if (this.theReportId <> null && String.isNotEmpty(this.theReportId)) {
            this.reportResults = VT_ReportResultsHelper.getReportResponse(theReportId);
            this.reportExecuted = true;
        }

        return null;
    }

}