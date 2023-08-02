package org.example;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static java.lang.System.exit;

public class Parser {
    //findFiles from https://mkyong.com/java/how-to-find-files-with-certain-extension-only/
    public static List<String> findFiles(Path path, String fileExtension)
            throws IOException {

        if (!Files.isDirectory(path)) {
            throw new IllegalArgumentException("Path must be a directory!");
        }

        List<String> result;

        try (Stream<Path> walk = Files.walk(path)) {
            result = walk
                    .filter(p -> !Files.isDirectory(p))
                    // this is a path, not string,
                    // this only test if path end with a certain path
                    //.filter(p -> p.endsWith(fileExtension))
                    // convert path to string first
                    .map(p -> p.toString().toLowerCase())
                    .filter(f -> f.endsWith(fileExtension))
                    .collect(Collectors.toList());
        }

        return result;
    }
    public String checkValidity(String folder){
        File file = new File(folder);
        String userdir = System.getProperty("user.dir");
        File file2 = new File(userdir +"/input/"+folder);
        if (!file.isDirectory() && !file2.isDirectory()){
            System.out.println("You have not provided a directory, please correct the file path.");
            return "NF";
        }else{
            if (file.isDirectory()){
                folder = file.getPath();
            }else{
                folder = file2.getPath();
            }
            System.out.println("Directory found, getting cloud function...");
            return getCloudFunction(folder);
        }

    }
    public String getCloudFunction(String folder){
        try {
            Path path = Paths.get(folder);
            List<String> files = findFiles(path, ".py");
            files.addAll(findFiles(path, ".js"));
            files.addAll(findFiles(path, ".ts"));
            System.out.println(Arrays.toString(files.toArray()));
            if(files.size() == 1){
                System.out.println("Cloud function found with name "+ files.get(0));
                return files.get(0);
            }else if(files.size() == 0){
                System.out.println("No function with ending .py/.js/.ts found, exiting..");
                exit(1);
            }else{
                System.out.println("Multiple possible functions found, please specify the function");
                Scanner scanTool = new Scanner(System.in);
                String function = scanTool.nextLine();
                return(folder + "/" + function);
            }
        }catch (IOException e) {
            e.printStackTrace();
        }

        return "stub";
    }

}
