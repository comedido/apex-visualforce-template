/**********************************************************************************
* @author       Aaron Dominguez - aaron@nube53.com
* @date         16 January 2017
* @description  Base Controller to be extended by every controller.
* @Revision     [AD] - 16/01/2017 - Initial version.
**********************************************************************************/
public abstract class VT_BaseController {
    
    //-- CONSTANTS
    private static final Id theUserId = UserInfo.getUserId();
    //public static final VT_UtilsRecordType recordTypeUtils = VT_UtilsRecordType.getInstance();

    //-- ATTRIBUTES
    // Template global variables
    public String pageDeviceInfo {get; protected set;}
    public String metaTitleInfo {get; protected set;}
    public String metaDescriptionInfo {get; set;}
    public String jsMainResourcesInfo {get {return 'true';} protected set;}
    public String cssMainResourcesInfo {get {return 'true';} protected set;}
    public List<String> jsExtensionResourcesInfo {get; protected set;}
    public List<String> cssExtensionResourcesInfo {get; protected set;}

    public boolean canAccessPage {get ;set;}

    //VARIABLES
    public Contact contactInContext;

    //-- CONSTRUCTORS
    /**
     * Main contructor method. NEVER USED.
     *
     * @param
     */
    public VT_BaseController() {}

    //-- ABSTRACT METHODS - Low-level
    /**
     * All controllers must implement this method to initialise the controller in context
     *
     * @param
     */
    protected abstract void initialise();
    /**
     * All controllers must implement the Exceptions handler method.
     *
     * @param
     * @return Boolean result
     */
    protected abstract Boolean pageHasInitExceptions();

    /**
     * All controllers must implement this method to define Template's global variables
     *
     * @param
     */
    protected abstract void setTemplateGlobalVariables();

    //-- VIRTUAL METHODS - High-level
    /**
     * Method to be called in most pages. Avoid using it in Login/Logout/Register pages.
     *
     * @param
     * @return Contact the contact from User in context
     */
    public virtual Contact retrieveContactFromUserInContext() {
    	if(this.contactInContext == null) {
    		try {
    			this.contactInContext = new Contact();
    			List<Contact> theContacts = new List<Contact>();
    			theContacts = [SELECT Id, 
                                      FirstName, 
                                      LastName, 
                                      Email,
                                      Phone, 
                                      AccountId, 
                                      Account.Name,
                                      Account.BillingStreet,
                                      Account.BillingPostalCode,
                                      Account.BillingCity
    						   FROM Contact
    						   WHERE Id IN (SELECT ContactId FROM User WHERE Id =: theUserId)
    						   LIMIT :System.Limits.getLimitQueryRows()];
    			if(theContacts.isEmpty())
    				return null;
    			this.contactInContext = theContacts.get(0);	
    			return this.contactInContext;
			} catch(Exception theException) {
				//throw new VT_CustomException('Impossible to identify user',null,VT_CustomException.Code.EX_000001);
			}
    	} else {
    		return this.contactInContext;
    	}
    	return null;
    }

}