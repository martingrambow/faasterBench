package org.example;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.BasicParser;

import java.io.IOException;

import static java.lang.System.exit;

public class Main {
    public static void main(String[] args) throws ParseException, IOException {
        Options options = new Options();
        options.addOption("f",true,"Absolute or relative path to your first folder (default : input/dir1)");
        options.addOption("s",true,"Absolute or relative path to your second folder (default : input/dir2)");
        options.addOption("a", false,"Async FaaS function?");
        options.addOption("h",false,"Provide flag if help is wanted");
        CommandLineParser parser = new BasicParser();
        CommandLine cmd = parser.parse(options, args);
        Boolean aSyncReq = false;
        if(cmd.hasOption("h")){
            System.out.print("Usage:\r\n" +
                    "Stub" +
                    "Stub");
        }
        
        System.out.println("----------------------");
        System.out.println("Welcome to faasterBench!");
        System.out.println("----------------------");
        System.out.println("Working Directory = " + System.getProperty("user.dir"));
        //setup options
        String firstFolder = "input/default/dir1";
        String secondFolder = "input/default/dir2";
        if(cmd.hasOption("a")){
            aSyncReq = true;
            System.out.println("Async function required");
        }else{
            System.out.println("no option -a detected");
        }
        if(cmd.hasOption("f")){
            firstFolder = cmd.getOptionValue("f");
        }else{
            System.out.println("No value provided for first folder, using default location : "+firstFolder);
        }
        if(cmd.hasOption("s")){
            secondFolder = cmd.getOptionValue("s");
        }else{
            System.out.println("No value provided for second folder, using default location : "+secondFolder);
        }


        Parser parseTool = new Parser();
        Wrapper wrapTool = new Wrapper();

        //check if simple wrapper build or advanced is required 
        if(firstFolder.endsWith("aws") || firstFolder.endsWith("google")){
            System.out.println("Advanced setup required due to different configurations for aws/google");
            if(firstFolder.endsWith("google")){
                wrapTool.buildWrapper(firstFolder, secondFolder, aSyncReq);
            }else{
                wrapTool.buildWrapper(secondFolder, firstFolder, aSyncReq);
            }
        }else{
            //ask for first folder
            String cloudFunction1 = parseTool.checkValidity(firstFolder);
            if(cloudFunction1.equals("NF")) {
                System.out.println("Invalid value provided for first folder: "+ firstFolder+ ", exiting..");
                exit(1);
            }
            String cloudFunction2 = parseTool.checkValidity(secondFolder);
            if(cloudFunction2.equals("NF")) {
                System.out.println("Invalid value provided for second folder: "+ secondFolder+ ", exiting..");
                exit(1);
            }
            //ask for second folder
            if(cloudFunction1.substring(cloudFunction1.indexOf(".")).equals(cloudFunction2.substring(cloudFunction2.indexOf(".")))){
                System.out.println("Proceeding with building of wrapper function using "+ cloudFunction1 + " and "+ cloudFunction2);
                wrapTool.buildWrapper(cloudFunction1, cloudFunction2, aSyncReq);
            }else{
                //function type mismatch, abort
                System.out.println("Functions are of different types "+ cloudFunction1.substring(cloudFunction1.indexOf(".")) + " and "+ cloudFunction2.substring(cloudFunction2.indexOf(".")) + ", aborting Cloudwrap.");
                exit(1);
            }
        }  
    }
}