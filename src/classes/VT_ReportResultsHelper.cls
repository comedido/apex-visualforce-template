/**********************************************************************************
* @author       Aaron Dominguez - aaron@nube53.com
* @date         20 October 2016
* @description  Helper class to expose Report results
* @Revision     [AD] - 20/10/2016 - Initial version.
**********************************************************************************/
public with sharing class VT_ReportResultsHelper {

	//-- CONSTANTS
	private static final String REPORT_TYPE_TABULAR = 'tabular';
	private static final String REPORT_TYPE_SUMMARY = 'summary';
	private static final String REPORT_TYPE_MATRIX = 'matrix';
    
    /**
    * Main entry point to get the results of a report by passing its Id
    * @param reportId{@code Id}
    *
    * @return reportResponse{@code reportResponse}
    */
    public static reportResponse getReportResponse(Id reportId) {

		// results variable will contain the results of executing the report received by Id
		Reports.ReportResults results = Reports.ReportManager.runReport(reportId, true);
		
		// reportMetadata will contain the report metadata
		Reports.ReportMetadata reportMetadata = results.getReportMetadata();
		
		// GroupingsDown y GroupingAcross info from reportMetadata
		// it will evaluate the type of report (tabular, summary o matrix).
		Integer groupingsDown = 0;
		Integer groupingsAcross = 0;
		
		List<Reports.GroupingInfo> groupingDownList = reportMetadata.getGroupingsDown();
		List<Reports.GroupingInfo> groupingAcrossList = reportMetadata.getGroupingsAcross();
		
		if (groupingDownList != null) {
			groupingsDown = groupingDownList.size();
		}
		
		if (groupingDownList != null) {
			groupingsAcross = groupingAcrossList.size();
		}		
		
		String reportType = REPORT_TYPE_TABULAR;
		if ( (groupingsDown > 0) && (groupingsAcross == 0) ) {
			reportType = REPORT_TYPE_SUMMARY;	
		}
		
		if ( (groupingsDown > 0) && (groupingsAcross > 0) ) {
			reportType = REPORT_TYPE_MATRIX;	
		}		
		
        // Let's gather the report fields, rows and columns based on report type
		reportResponse rr = new reportResponse();
		rr.reportType = reportType;	
		
		if (reportType == REPORT_TYPE_TABULAR) {
			rr.tabResp = getTabularReportResponse(results);
		} else if (reportType == REPORT_TYPE_SUMMARY) {
			rr.sumResp = getSummaryReportResponse(results);
		} else if (reportType == REPORT_TYPE_MATRIX) {
			rr.tabResp = getMatrixReportResponse(results);
		}
		
		return rr;
	}

    /**
    * Results for tabular reports
    * @param results{@code Reports.ReportResults}
    *
    * @return tabularReportResponse{@code reportResponse}
    */
	private static tabularReportResponse getTabularReportResponse(Reports.ReportResults results) {
		
        tabularReportResponse trr = new tabularReportResponse();
		List<fieldDef> reportFields = new List<fieldDef>();	
		List<List<fieldData>> fieldDataList = new List<List<fieldData>>();	
		
		// It retrieves the metadata info
		Reports.ReportMetadata reportMetadata = results.getReportMetadata();

		// It retrieves a String list with field names (columns)
		List<String> fieldNames = reportMetadata.getDetailColumns();		
		
		// It retrieves extended metadata info
		Reports.ReportExtendedMetadata reportExtendedMetadata = results.getReportExtendedMetadata();

		// It matches column names with labels
		Map<String, Reports.DetailColumn> detailColumnMap = reportExtendedMetadata.getDetailColumnInfo();
			
		// It loops over detailColumnMap and populates reportFields with field names,
		// labels and field types
		for (String fieldName: fieldNames) {
			Reports.DetailColumn detailColumn = detailColumnMap.get(fieldName);
			fieldDef fd = new fieldDef();
			fd.fieldName = detailColumn.getName(); 
			fd.fieldLabel = detailColumn.getLabel();
			fd.dataType = detailColumn.getDataType().name();
			reportFields.add(fd);
		}
		
		// It retrieves the fact map results	
		Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');		
		
		List<Reports.ReportDetailRow> reportDetailRowList = factDetails.getRows();
		
		// It loops over reportDetailRowList filling fieldDataList with 
		// row data
		for (Reports.ReportDetailRow reportDetailRow: reportDetailRowList) {
			Integer cellCounter = 0;
            String miLabel = '';
            String miValue = '';
			List<fieldData> fieldDataRow = new List<fieldData>();
			//loop over the cells in the row
			for (Reports.ReportDataCell reportDataCell: reportDetailRow.getDataCells()) {
				fieldData fd = new fieldData();
                fd.dataType = reportFields[cellCounter].dataType;
                if (fd.dataType != 'STRING_DATA') {
                    miLabel = String.valueOf(reportDataCell.getLabel());
                    miValue = String.valueOf(reportDataCell.getValue());
                } else {
                    miLabel = reportDataCell.getLabel();
                    miValue = String.valueOf(reportDataCell.getValue());
                }
                fd.fieldLabel = miLabel;
                fd.fieldValue = (String)miValue;
				fd.isHyperLink = isHyperlink(fd.fieldValue);
				cellCounter++;
				fieldDataRow.add(fd);
			}
			
			//add the row to the list
			fieldDataList.add(fieldDataRow);
		}

		trr.reportFields = reportFields;
		trr.fieldDataList = fieldDataList;
		return trr;
	}	

    /**
    * Results for summary reports
    * @param results{@code Reports.ReportResults}
    *
    * @return tabularReportResponse{@code reportResponse}
    */
	private static summaryReportResponse getSummaryReportResponse(Reports.ReportResults results) {
		summaryReportResponse srr = new summaryReportResponse();
		List<fieldDef> reportFields = new List<fieldDef>();	
		
		// It retrieves the metadata info
		Reports.ReportMetadata reportMetadata = results.getReportMetadata();

		// It retrieves a String list with field names (columns)
		List<String> fieldNames = reportMetadata.getDetailColumns();		
		
		// It retrieves extended metadata info
		Reports.ReportExtendedMetadata reportExtendedMetadata = results.getReportExtendedMetadata();

		// It matches column names with labels
		Map<String, Reports.DetailColumn> detailColumnMap = reportExtendedMetadata.getDetailColumnInfo();
		
		// It matches column subtotals from groups with name an label
		Map<String, Reports.GroupingColumn> groupingColumnMap = reportExtendedMetadata.getGroupingColumnInfo();		

		// It retrieves the info from group columns
		Reports.GroupingInfo groupingInfo = reportMetadata.getGroupingsDown()[0]; //First element from grouping only
		Reports.GroupingColumn groupingColumnDetail = groupingColumnMap.get(groupingInfo.getName());				
		
		// It loops over detailColumnMap and stores in reportFields names, labels and data types
		for (String fieldName: fieldNames) {
			Reports.DetailColumn detailColumn = detailColumnMap.get(fieldName);
			fieldDef fd = new fieldDef();
			fd.fieldName = detailColumn.getName(); 
			fd.fieldLabel = detailColumn.getLabel();
			fd.dataType = detailColumn.getDataType().name();
			reportFields.add(fd);
		}
		srr.reportFields = reportFields;
		
		// It retrieves values from summmary first level groups
		List<summaryReportGroup> groupList = new List<summaryReportGroup>();
		for (Reports.GroupingValue groupingValue: results.getGroupingsDown().getGroupings()) {
			summaryReportGroup srg = new summaryReportGroup();
			srg.fieldName = groupingColumnDetail.getLabel();			
			srg.fieldValue = (String)groupingValue.getValue();
			srg.fieldLabel = groupingValue.getLabel();
			srg.groupKey = groupingValue.getKey();
			srg.isHyperLink = isHyperlink(srg.fieldValue);
			
			// It uses the group key value to obtain the group rows fromm fact map
			Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(srg.groupKey+'!T');	
			List<Reports.ReportDetailRow> reportDetailRowList = factDetails.getRows();			

			List<List<fieldData>> fieldDataList = new List<List<fieldData>>();
			
			// It iterates over reportDetailRowList rows				
			for (Reports.ReportDetailRow reportDetailRow: reportDetailRowList) {
				Integer cellCounter = 0;
                String miLabel = '';
                String miValue = '';
				List<fieldData> fieldDataRow = new List<fieldData>();
				// It iterates over every row's DataCells
				for (Reports.ReportDataCell reportDataCell: reportDetailRow.getDataCells()) {
					fieldData fd   = new fieldData();
                    fd.dataType    = reportFields[cellCounter].dataType;
                    if (fd.dataType != 'STRING_DATA') {
                        miLabel = String.valueOf(reportDataCell.getLabel());
                        miValue = String.valueOf(reportDataCell.getValue());
                    } else {
                        miLabel = reportDataCell.getLabel();
                        miValue = String.valueOf(reportDataCell.getValue());
                    }                    
					fd.fieldLabel  = miLabel;                    
					fd.fieldValue  = (String)miValue;					
					fd.isHyperLink = isHyperlink(fd.fieldValue);
					cellCounter++;
					fieldDataRow.add(fd);
				}
				// It adds the row to the list
				fieldDataList.add(fieldDataRow);
			}			
			srg.fieldsInGroup = srr.reportFields.size();			
			srg.fieldDataList = fieldDataList;
			groupList.add(srg);
		}
		srr.groupList = groupList;
		return srr;
	}		

    
    /**
    * Results for matrix reports
    * @param results{@code Reports.ReportResults}
    *
    * @return tabularReportResponse{@code reportResponse}
    */
	private static tabularReportResponse getMatrixReportResponse(Reports.ReportResults results) {
		tabularReportResponse trr = new tabularReportResponse();
		List<fieldDef> reportFields = new List<fieldDef>();
		List<List<fieldData>> fieldDataList = new List<List<fieldData>>();		
		
		// It retrieves the metadata info
		Reports.ReportMetadata reportMetadata = results.getReportMetadata();

		// It retrieves a String list with field names (columns)
		List<String> fieldNames = reportMetadata.getDetailColumns();		
		
		// It retrieves extended metadata info
		Reports.ReportExtendedMetadata reportExtendedMetadata = results.getReportExtendedMetadata();

		// It matches column names with labels
		Map<String, Reports.GroupingColumn> detailColumnMap = reportExtendedMetadata.getGroupingColumnInfo();
		
		// It adds info from grouping
		Reports.GroupingInfo groupingInfoDown = reportMetadata.getGroupingsDown()[0]; //only supports one grouping level
		Reports.GroupingColumn groupingColumnDown = detailColumnMap.get(groupingInfoDown.getName());
		fieldDef fdGroupDown = new fieldDef();
		fdGroupDown.fieldName = groupingColumnDown.getName(); 
		fdGroupDown.fieldLabel = groupingColumnDown.getLabel();
		fdGroupDown.dataType = groupingColumnDown.getDataType().name();
		reportFields.add(fdGroupDown);
		
		// It adds groupings across
		for (Reports.GroupingValue groupingValue: results.getGroupingsAcross().getGroupings()) {
			fieldDef fd = new fieldDef();
			fd.fieldName = (String)groupingValue.getValue(); 
			fd.fieldLabel = groupingValue.getLabel();
			fd.dataType = 'DOUBLE_DATA';
			reportFields.add(fd);			
		}				
		
		// It obtains dimension values of matrox report GroupingDown down to 1 level only
		List<summaryReportGroup> groupListDown = new List<summaryReportGroup>();
		for (Reports.GroupingValue groupingValue: results.getGroupingsDown().getGroupings()) {
			summaryReportGroup srg = new summaryReportGroup();
			srg.fieldValue = (String)groupingValue.getValue();
			srg.fieldLabel = groupingValue.getLabel();
			srg.groupKey = groupingValue.getKey();
			srg.isHyperLink = isHyperlink(srg.fieldValue);
			groupListDown.add(srg);
		}
		
		// It obtains dimension values of matrox report GroupingAcross down to 1 level only
		List<summaryReportGroup> groupListAcross = new List<summaryReportGroup>();
		for (Reports.GroupingValue groupingValue: results.getGroupingsAcross().getGroupings()) {
			summaryReportGroup srg = new summaryReportGroup();
			srg.fieldValue = (String)groupingValue.getValue();
			srg.fieldLabel = groupingValue.getLabel();
			srg.groupKey = groupingValue.getKey();
			srg.isHyperLink = isHyperlink(srg.fieldValue);
			groupListAcross.add(srg);
		}		

		// It iterates GroupingsDown and GroupingsAcross in order to obtain fact map data
		for (summaryReportGroup down: groupListDown) {
			List<fieldData> fieldDataRow = new List<fieldData>();

			// First cell of grouping down
			fieldData fd = new fieldData();
			fd.fieldValue = down.fieldValue;
			fd.fieldLabel = down.fieldLabel;
			fd.dataType = 'STRING_DATA';
			fd.isHyperLink = down.isHyperLink;
			fieldDataRow.add(fd);					
			
			for (summaryReportGroup across: groupListAcross) {
				Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(down.groupKey+'!'+across.groupKey);	
				Reports.SummaryValue summaryValue = factDetails.getAggregates()[0]; //Sólo el primer nivel.
				
				fd = new fieldData();
				fd.fieldValue = (String)(summaryValue.getValue()+'');
				fd.fieldLabel = (String)(summaryValue.getLabel()+'');
				fd.dataType = 'DOUBLE_DATA';
				fieldDataRow.add(fd);						
					
			}
			//It adds the row to fieldDataList
			fieldDataList.add(fieldDataRow);
		}

		trr.reportFields = reportFields;
		trr.fieldDataList = fieldDataList;
		
		return trr;
	}			

	/**
    * Returns whether a field is Hyperlink or not
    * @param String{@code sVal}
    *
    * @return Boolean
    */
	public static Boolean isHyperlink(String sVal) {
		Boolean isHyperLink = true;
		Id theId;
		try {theId = (Id)sVal;}
		catch (Exception e) {isHyperLink = false;}
		return isHyperLink;
	}	
		
	//-- INNER CLASSES
	// reportResponse wrapper
	public class reportResponse {
		public String reportType {get; set;}
		public tabularReportResponse tabResp {get; set;}
		public summaryReportResponse sumResp {get; set;}		
		public reportResponse(){}
	}	
	
	// summaryReportResponse wrapper
	public class summaryReportResponse {
		public List<fieldDef> reportFields {get; set;}
		public List<summaryReportGroup> groupList {get; set;}
		public summaryReportResponse(){}
	}	

	// summaryReportGroup wrapper
	public class summaryReportGroup {
		public String fieldName {get; set;}
		public String fieldValue {get; set;}
		public String fieldLabel {get; set;}
		public String groupKey {get; set;}
		public Boolean isHyperLink {get; set;}	
		public Integer fieldsInGroup {get; set;}					
		public List<List<fieldData>> fieldDataList {get; set;}
		public summaryReportGroup(){}
	}		

	// tabularReportResponse wrapper
	public class tabularReportResponse {
		public List<fieldDef> reportFields {get; set;}
		public List<List<fieldData>> fieldDataList {get; set;}
		public tabularReportResponse(){}
	}
	
	// fieldDef  wrapper
    public class fieldDef {
		public String fieldName {get; set;}
		public String fieldLabel {get; set;}
		public String dataType {get; set;}
		public fieldDef(){}
	}

    // fieldData wrapper
	public class fieldData {
		public String fieldValue {get; set;}
		public String fieldLabel {get; set;}
		public String dataType  {get; set;}
		public Boolean isHyperLink {get; set;}			
		public fieldData(){isHyperLink=false;}
	}

}