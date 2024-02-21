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
        options.addOption("f",true,"Absolute or relative path to your first folder (default : input/cpu/dir1)");
        options.addOption("s",true,"Absolute or relative path to your second folder (default : input/cpu/dir2)");
        options.addOption("t", true, "Absolute or relative path to your third folder(if functions differ by provider) Default : None");
        options.addOption("a", false,"Set this flag to specify that you are utilizing at least one asynchronous function");
        options.addOption("h",false,"Provide flag if help is wanted");
        options.addOption("i",true,"Provide flag if a cpu/network/memory benchmark should be injected into the wrapper and run before the actual function execution. After the flag, add 'c','n','m', or multiple to run the respective benchmarks");
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
        String firstFolder = "input/cpu/dir1";
        String secondFolder = "input/cpu/dir2";
        String thirdFolder = "";
        String benchmarksToBeRun = "";
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
        if(cmd.hasOption("t")){
            thirdFolder = cmd.getOptionValue("t");
        }else{
            System.out.println("No value provided for second folder, using default location : "+thirdFolder);
        }
        if(cmd.hasOption("i")){
            String injectOutput = "";
            benchmarksToBeRun = cmd.getOptionValue("i");
            if(benchmarksToBeRun.contains("c")){
                injectOutput += "CPU, ";
            }
            if(benchmarksToBeRun.contains("n")){
                injectOutput += "Network, ";
            }
            if(benchmarksToBeRun.contains("m")){
                injectOutput += "Memory, ";
            }
            if(injectOutput.length()>0){
                injectOutput = injectOutput.substring(0,injectOutput.length()-2);
            }
            System.out.println("Benchmarks to be injected: "+injectOutput);
        }

        Parser parseTool = new Parser();
        Wrapper wrapTool = new Wrapper();


        //check if simple wrapper build or advanced is required 
        if(firstFolder.endsWith("aws") || firstFolder.endsWith("google") || firstFolder.endsWith("azure")){
            System.out.println("Advanced setup required due to different configurations for aws/google");
            if(firstFolder.endsWith("google")){
                if(secondFolder.endsWith("aws")){
                    wrapTool.buildWrapper(firstFolder, secondFolder, thirdFolder, aSyncReq);
                }else{
                    wrapTool.buildWrapper(firstFolder, thirdFolder, secondFolder, aSyncReq);
                }
            }else if(firstFolder.endsWith("aws")){
                if(secondFolder.endsWith("google")){
                    wrapTool.buildWrapper(secondFolder, firstFolder, thirdFolder, aSyncReq);
                }else{
                    wrapTool.buildWrapper(thirdFolder, firstFolder, secondFolder, aSyncReq);
                }
            }else{
                if(secondFolder.endsWith("google")){
                    wrapTool.buildWrapper(secondFolder, thirdFolder, firstFolder, aSyncReq);
                }else{
                    wrapTool.buildWrapper(thirdFolder, secondFolder, firstFolder, aSyncReq);
                }
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
                wrapTool.buildWrapper(cloudFunction1, cloudFunction2,"", aSyncReq);
            }else{
                //function type mismatch, abort
                System.out.println("Functions are of different types "+ cloudFunction1.substring(cloudFunction1.indexOf(".")) + " and "+ cloudFunction2.substring(cloudFunction2.indexOf(".")) + ", aborting Cloudwrap.");
                exit(1);
            }
        }  
    }
}