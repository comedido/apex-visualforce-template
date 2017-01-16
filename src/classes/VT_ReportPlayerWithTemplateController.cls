/**********************************************************************************
* @author       Aaron Dominguez - aaron@nube53.com
* @date         16 January 2017
* @description  Controller class for VT_ReportPlayerWithTemplate page.
* @Revision     [AD] - 16/01/2017 - Initial version.
**********************************************************************************/
public class VT_ReportPlayerWithTemplateController extends VT_BaseController {
    
    //-- CONSTANTS
    private static final String META_TITLE_INFO = System.Label.VT_REPORTTEMPLATE_META_TITLE;
    private static final String META_DESCRIPTION_INFO = System.Label.VT_REPORTTEMPLATE_META_DESCRIPTION;
    private static final String META_DEVICE_INFO = 'Desktop';
    private static final String SITE_HOME_REDIRECT = '/VT_ReportPlayerWithTemplate';
    private static final PageReference homeRedirect = new PageReference(SITE_HOME_REDIRECT);

    //-- ATTRIBUTES
    public String visitorFullName {get; set;}
    public Account theAccount {get; set;}
    public Contact theContact {get; set;}
    public String validationErrorMessage {get; set;}

    //-- CONSTRUCTORS
    public VT_ReportPlayerWithTemplateController() {
        // Set Page info through template global variables
        setTemplateGlobalVariables();
        // Initialisation
        initialise();
    }

    //-- HIGH-LEVEL METHODS i.e. Abstraction specific

    //-- LOW-LEVEL METHODS i.e. Implementation specific
    /**
     * All controllers must implement this method for initialisation.
     *
     * @param
     */
    protected override void initialise() {
    	//-- IF EXCEPTIONS, NO PARTY
    	if(pageHasInitExceptions()) {
    		//throw new VT_CustomException('Can\'t get it',null,VT_CustomException.Code.EX_000001);
    		return;
    	}
        this.validationErrorMessage = '';
    	//-- GO AHEAD
        // Gather userName
        this.visitorFullName = contactInContext.Account.Name;
        // Fetch Account
        fetchAccountFromContactId(contactInContext.AccountId);
        // Fetch Contact
        this.theContact = contactInContext;

    }
    /**
     * All controllers must implement this method the Exceptions handler method.
     *
     * @param
     */
    protected override Boolean pageHasInitExceptions() {
    	//-- PREVALIDATIONS
    	// Get User in Context
    	super.retrieveContactFromUserInContext();
        this.canAccessPage = TRUE;
        return FALSE;
    }

    protected override void setTemplateGlobalVariables() {
        this.pageDeviceInfo = META_DEVICE_INFO;
        this.metaTitleInfo = META_TITLE_INFO;
        this.metaDescriptionInfo = META_DESCRIPTION_INFO;
        // Load additional JS libraries
        this.jsExtensionResourcesInfo = new List<String>{'jquery','bootstrap'};
        // Load additional CSS libraries 
        this.cssExtensionResourcesInfo = new List<String>{'salesforce-lightning-design-system','material-design'};
    }

    //--ACTION METHODS
    /**
     * It will respond to an AJAX request
     * 
     * @param
     * @return 
     */
    public PageReference userAction() {
    	return null;
    }

    //--PRIVATE METHODS
     /**
     * It will retrieve the account for a customer
     * 
     * @param
     * @return 
     */
     private void fetchAccountFromContactId(final Id accountId) {
     	this.theAccount = new Account();
     	try {
	     	for(Account acc : [SELECT Id, Name, Phone,
	     							  BillingStreet, BillingCity, BillingState, BillingPostalCode,
	     							  ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
	     					   FROM Account
	     					   WHERE Id = :accountId
	     					   LIMIT 1]) {
	     		this.theAccount = acc;
	     	}
	    } catch (Exception theException) {
	    	//throw new VT_CustomException('Impossible to identify user',null,VT_CustomException.Code.EX_000001);
	    }
     }


}