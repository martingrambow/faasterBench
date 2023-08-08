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
        options.addOption("c",false,"Stub-> Flag used if complexity should be added (default : false");
        options.addOption("h",false,"Provide flag if help is wanted");
        CommandLineParser parser = new BasicParser();
        CommandLine cmd = parser.parse(options, args);
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
        //String firstFolder = "input/dir1";
        //String secondFolder = "input/dir2";
        String firstFolder = "wrapper/input/dir1";
        String secondFolder = "wrapper/input/dir2";

        String cloudProvider = "gcp";
        boolean addComplexity= false;
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
        if(cmd.hasOption("c")){
            addComplexity = true;
        }


        Parser parseTool = new Parser();
        Wrapper wrapTool = new Wrapper();

        //ask for cloud
        if(!(cloudProvider.equals("gcp") || cloudProvider.equals("aws"))){
            System.out.println("Invalid value provided for cloud provider: "+ cloudProvider+ ", exiting..");
            exit(1);
        }


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
            wrapTool.buildWrapper(cloudFunction1, cloudFunction2);
        }else{
            //function type mismatch, abort
            System.out.println("Functions are of different types "+ cloudFunction1.substring(cloudFunction1.indexOf(".")) + " and "+ cloudFunction2.substring(cloudFunction2.indexOf(".")) + ", aborting Cloudwrap.");
            exit(1);
        }
    }
}