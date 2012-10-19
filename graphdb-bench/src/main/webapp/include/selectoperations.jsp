<%@ page import="com.tinkerpop.bench.log.SummaryLogEntry"%>
<%@ page import="com.tinkerpop.bench.log.SummaryLogReader"%>
<%@ page import="com.tinkerpop.bench.util.*"%>
<%@ page import="com.tinkerpop.bench.web.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>

<%

/* 
 * VARIABLE EXPORT LIST
 */

// A set of selected operations 
TreeSet<String> selectedOperations = new TreeSet<String>();

// Map [operation name ---> a sorted set of jobs] for the selected database engine/instance pairs
TreeMap<String, SortedSet<Job>> operationToJobsMap = new TreeMap<String, SortedSet<Job>>();

// A map of selected database engine/instance pairs to a sorted set of all available jobs
HashMap<DatabaseEngineAndInstance, SortedSet<Job>> selectedDatabaseInstanceToJobsMap
	= new HashMap<DatabaseEngineAndInstance, SortedSet<Job>>();


/*
 * Main body
 */

if (true) {
	
	int numJobs = 0;
	int numOperations = 0;
	
	//boolean selectoperations_selectMultiple = WebUtils.getBooleanParameter(request, "select_multiple", false);
	
		
	// Map: operation name ---> set of relevant database engine/instance pairs 
	TreeMap<String, SortedSet<DatabaseEngineAndInstance>> operationMap
		= new TreeMap<String, SortedSet<DatabaseEngineAndInstance>>();
	
	
	// Get the map of all successfully completed jobs and the map of all available operations

	for (DatabaseEngineAndInstance p : selectedDatabaseInstances) {
		SortedSet<Job> m = new TreeSet<Job>();
		selectedDatabaseInstanceToJobsMap.put(p, m);
		for (Job job : JobList.getInstance().getFinishedJobs(p.getEngine().getShortName(), p.getInstance())) {
			
			if (job.getExecutionCount() < 0 || job.getLastStatus() != 0 || job.isRunning()) continue;
			File summaryFile = job.getSummaryFile();
			if (summaryFile == null) continue;
			if (job.getExecutionTime() == null) continue;
			
			
			// Jobs
			
			m.add(job);
			numJobs++;
			
			
			// Operation Maps
			
			SummaryLogReader reader = new SummaryLogReader(summaryFile);
			for (SummaryLogEntry e : reader) {
				String name = e.getName();
				if (name.equals("OperationOpenGraph")
						|| name.equals("OperationDoGC")
						|| name.equals("OperationShutdownGraph")) continue;
				
				if (name.startsWith("OperationLoadFGF-")) {
					name = "OperationLoadFGF-*";
				}
				if (name.startsWith("OperationLoadGraphML-")) {
					name = "OperationLoadGraphML-*";
				}
				
				SortedSet<DatabaseEngineAndInstance> dbis = operationMap.get(name);
				if (dbis == null) {
					dbis = new TreeSet<DatabaseEngineAndInstance>();
					operationMap.put(name, dbis);
				}
				
				SortedSet<Job> ojs = operationToJobsMap.get(name);
				if (ojs == null) {
					ojs = new TreeSet<Job>();
					operationToJobsMap.put(name, ojs);
				}
				
				dbis.add(p);
				ojs.add(job);
			}
		}
	}
	
	for (String n : operationMap.keySet()) {
		if (operationMap.get(n).size() == selectedDatabaseInstances.size()) numOperations++;
	}
	
	
	// Get the set of selected operations
	
	String[] a_selectedOperations = WebUtils.getStringParameterValues(request, "operations");
	if (a_selectedOperations != null) {
		for (String a : a_selectedOperations) {
			
			if (a.startsWith("OperationLoadFGF-")) {
				a = "OperationLoadFGF-*";
			}
			if (a.startsWith("OperationLoadGraphML-")) {
				a = "OperationLoadGraphML-*";
			}

			if (operationMap.containsKey(a)) {
				if (operationMap.get(a).size() == selectedDatabaseInstances.size()) {
					selectedOperations.add(a);
				}
			}
		}
	}

	
	// Operations
	
	if (numOperations > 0) {
		for (String n : operationMap.keySet()) {
			if (operationMap.get(n).size() != selectedDatabaseInstances.size()) continue;
			
			String extraTags = "";
			if (selectedOperations.contains(n)) {
				extraTags += " checked=\"checked\"";
			}
			
			String niceName = n;
			if (niceName.startsWith("Operation")) niceName = niceName.substring(9);
			
			%>
				<label class="checkbox">
					<input class="checkbox" type="<%= selectoperations_selectMultiple ? "checkbox" : "radio" %>" name="operations"
							onchange="form_submit();" <%= extraTags %>
							value="<%= n %>"/>
					<%= niceName %>
				</label>
			<%
		}
	}
}
%>