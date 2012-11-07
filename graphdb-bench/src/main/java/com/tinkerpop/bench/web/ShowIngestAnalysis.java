package com.tinkerpop.bench.web;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import au.com.bytecode.opencsv.CSVWriter;

import com.tinkerpop.bench.DatabaseEngine;
import com.tinkerpop.bench.analysis.IngestAnalysis;


/**
 * A servlet for showing the results of ingest analysis
 * 
 * @author Peter Macko (pmacko@eecs.harvard.edu)
 */
@SuppressWarnings("serial")
public class ShowIngestAnalysis extends HttpServlet {
	
	/**
	 * Create an instance of class ShowIngestAnalysis
	 */
	public ShowIngestAnalysis() {
	}

	
	/**
	 * Respond to a POST request
	 */
	@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
		doGet(request, response);
    }
	
	
	/**
	 * Respond to a GET request
	 */
	@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
		
		// Get the database engine name / instance name pairs
		
		String[] pairs = WebUtils.getStringParameterValues(request, "database_engine_instance");
		List<DatabaseEngineAndInstance> dbeis = new ArrayList<DatabaseEngineAndInstance>();
		
		if (pairs != null) {
			for (String p : pairs) {
				int d = p.indexOf('|');
				dbeis.add(new DatabaseEngineAndInstance(DatabaseEngine.ENGINES.get(p.substring(0, d)), p.substring(d+1)));
			}
		}
		
		
		// Other parameters
		
		String format = WebUtils.getStringParameter(request, "format");
		if (format == null) format = "plain";
		
		
		// Get the writer and write out the information
		
		PrintWriter writer = response.getWriter();
		printIngestAnalysis(writer, dbeis, format, response);
	}
	
	
	/**
	 * Write out the ingest analysis to the given writer
	 * 
	 * @param writer the writer
	 * @param dbeis  the database engine name / instance name pairs
	 * @param format the format
	 * @param response the response, or null if none
	 */
	public static void printIngestAnalysis(PrintWriter writer, Collection<DatabaseEngineAndInstance> dbeis, String format, HttpServletResponse response) {
		
		// Depending on the format type...
		
		if ("html".equals(format)) {
			if (response != null) {
		        response.setContentType("text/html");
		        response.setStatus(HttpServletResponse.SC_OK);
			}
	        
			writer.println("<table class=\"basic_table\">");
			writer.println("<tr>");
			writer.println("\t<th>Database Engine</th>");
			writer.println("\t<th>Database Instance</th>");
			writer.println("\t<th>Bulk Load (s)</th>");
			writer.println("\t<th>Shutdown after Bulk Load (ms)</th>");
			writer.println("\t<th>Incremental Load (s)</th>");
			writer.println("\t<th>Shutdown after Incremental Load (s)</th>");
			writer.println("\t<th>Index Creation (s)</th>");
			writer.println("\t<th>Shutdown after Index Creation (s)</th>");
			writer.println("\t<th>Total (s)</th>");
			writer.println("</tr>");

			for (DatabaseEngineAndInstance dbei : dbeis) {
				IngestAnalysis ia = IngestAnalysis.getInstance(dbei);
				writer.println("<tr>");
				writer.println("\t<td>" + dbei.getEngine().getLongName() + "</td>");
				writer.println("\t<td>" + dbei.getInstanceSafe("&lt;default&gt;") + "</td>");
				writer.println("\t<td class=\"numeric\">" + String.format("%.3f", ia.getBulkLoadTime()/1000.0) + "</td>");
				writer.println("\t<td class=\"numeric\">" + String.format("%.3f", ia.getBulkLoadShutdownTime()/1000.0) + "</td>");
				writer.println("\t<td class=\"numeric\">" + String.format("%.3f", ia.getIncrementalLoadTime()/1000.0) + "</td>");
				writer.println("\t<td class=\"numeric\">" + String.format("%.3f", ia.getIncrementalLoadShutdownTime()/1000.0) + "</td>");
				writer.println("\t<td class=\"numeric\">" + String.format("%.3f", ia.getCreateIndexTime()/1000.0) + "</td>");
				writer.println("\t<td class=\"numeric\">" + String.format("%.3f", ia.getCreateIndexShutdownTime()/1000.0) + "</td>");
				writer.println("\t<td class=\"numeric\">" + String.format("%.3f", ia.getTotalTime()/1000.0) + "</td>");
				writer.println("</tr>");
			}
			writer.println("</table>");
		}
		
		else if ("csv".equals(format)) {
			if (response != null) {
		        response.setContentType("text/plain");
		        response.setStatus(HttpServletResponse.SC_OK);
			}
	        
	        CSVWriter w = new CSVWriter(writer);
	        String[] buffer = new String[9];
	        
	        int index = 0;
	        buffer[index++] = "dbengine";
        	buffer[index++] = "dbinstance";
        	buffer[index++] = "type";
        	buffer[index++] = "field";
        	buffer[index++] = "label";
        	buffer[index++] = "mean";
        	buffer[index++] = "stdev";
        	buffer[index++] = "min";
        	buffer[index++] = "max";
        	assert index == buffer.length;
	        
	        w.writeNext(buffer);
	        
	        String lastInstance = null;
	        
			for (DatabaseEngineAndInstance dbei : dbeis) {
				IngestAnalysis ia = IngestAnalysis.getInstance(dbei);
				String s;
				int i;
				
				 
				// Group by placeholders
	        	
	        	//if ("operation".equals(groupBy)) {
				// XXX Hack, beware!
	        		if (lastInstance != null && !dbei.getInstanceSafe().equals(lastInstance)) {
	        			for (int j = 0; j < buffer.length; j++) buffer[j] = "";
	        			buffer[4] = "----" + lastInstance;
		        		w.writeNext(buffer);
		        		lastInstance = dbei.getInstanceSafe();
	        		}
	        		if (lastInstance == null) lastInstance = dbei.getInstanceSafe();
	        	//}

	        	
	        	// Data
	        	
	        	index = 0;
				buffer[index++] = dbei.getEngine().getLongName();
				buffer[index++] = dbei.getInstanceSafe("<default>");
				buffer[index++] = "observed";
				
				i = index; s = Double.toString(1000000.0 * ia.getBulkLoadTime() / 1000.0 /* HACK, beware! */ );
				buffer[i++] = "Bulk Load";
				buffer[i++] = buffer[0] + " : " + buffer[1] + " : " + buffer[3] + " : " + buffer[2];
				buffer[i++] = s; buffer[i++] = "0"; buffer[i++] = s; buffer[i++] = s;
				w.writeNext(buffer);
				
				i = index; s = Double.toString(1000000.0 * ia.getBulkLoadShutdownTime() / 1000.0 /* HACK, beware! */ );
				buffer[i++] = "Shutdown after Bulk Load";
				buffer[i++] = buffer[0] + " : " + buffer[1] + " : " + buffer[3] + " : " + buffer[2];
				buffer[i++] = s; buffer[i++] = "0"; buffer[i++] = s; buffer[i++] = s;
				w.writeNext(buffer);
				
				i = index; s = Double.toString(1000000.0 * ia.getIncrementalLoadTime() / 1000.0 /* HACK, beware! */ );
				buffer[i++] = "Incremental Load";
				buffer[i++] = buffer[0] + " : " + buffer[1] + " : " + buffer[3] + " : " + buffer[2];
				buffer[i++] = s; buffer[i++] = "0"; buffer[i++] = s; buffer[i++] = s;
				w.writeNext(buffer);
				
				i = index; s = Double.toString(1000000.0 * ia.getIncrementalLoadShutdownTime() / 1000.0 /* HACK, beware! */ );
				buffer[i++] = "Shutdown after Incremental Load";
				buffer[i++] = buffer[0] + " : " + buffer[1] + " : " + buffer[3] + " : " + buffer[2];
				buffer[i++] = s; buffer[i++] = "0"; buffer[i++] = s; buffer[i++] = s;
				w.writeNext(buffer);
				
				i = index; s = Double.toString(1000000.0 * ia.getCreateIndexTime() / 1000.0 /* HACK, beware! */ );
				buffer[i++] = "Index Creation";
				buffer[i++] = buffer[0] + " : " + buffer[1] + " : " + buffer[3] + " : " + buffer[2];
				buffer[i++] = s; buffer[i++] = "0"; buffer[i++] = s; buffer[i++] = s;
				w.writeNext(buffer);
				
				i = index; s = Double.toString(1000000.0 * ia.getCreateIndexShutdownTime() / 1000.0 /* HACK, beware! */ );
				buffer[i++] = "Shutdown after Index Creation";
				buffer[i++] = buffer[0] + " : " + buffer[1] + " : " + buffer[3] + " : " + buffer[2];
				buffer[i++] = s; buffer[i++] = "0"; buffer[i++] = s; buffer[i++] = s;
				w.writeNext(buffer);
			}
		}
		
		else {
			if (response != null) {
		        response.setContentType("text/plain");
		        response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
			}
	        
	        writer.println("Invalid format.");
		}		
	}
}
