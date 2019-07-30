# The Object Integration Process
( https://dev.osf-global.com/jira/browse/COBRA-134 )

### Batch flow:
1) A first query is performed to find the Metadata record that is activated. Metadata is used for integration settings purposes.
2) The last value founded on this metadata is used to filter another query for the next objects to be processed.
3) Objects are processed (translated).
4) Last value for the used metadata is updated. 
The process is pointed in three basic steps on comments at osf_AccountSourceBatch class.

### Testing:
1) Clone this repository.
2) Create a scratch org and push this project.
3) Import records provided on /data/sample-data-plan.json file.
4) Make changes on osf_Account_Source__c
5) Open developer console.
6) Choose a future time (CRON time-based) to run the test job.
7) Open execute anonymous window, and create an Apex scheduler by running the code bellow.
8) After the batch is completed, verify changes reflected on osf_Account_Target__c.

```
osf_AccountSourceSchedule schedule = new osf_AccountSourceSchedule();
String cron = '0 59 10 * * ?';
String jobID = system.schedule('New import job', cron, schedule);
System.debug('Schedule job ID: ' + jobID);
```

### Trigger flow:
1) A first query is performed to find the Metadata record that is activated. Metadata is used for integration settings purposes.
2) The triggered sobject (Trigger.new) is processed (translated).

### Testing:
1) Clone this repository.
2) Create a scratch org and push this project.
3) Import records provided on /data/sample-data-plan.json file.
4) Make changes on osf_Account_Source__c.
5) Verify changes reflected on osf_Account_Target__c.

If some warn appears or anything goes wrong, please verify the requirements:
1) Defined both source and target (custom) objects: for this sample code, osf_Account_Source__c and osf_Account_Target__c respectively.
2) Created a custom metadata type (osf_Account_Mapping__mdt) with the following custom fields, for each source-target pair of objects. Each record of this may represent general instructions about how to proceed with the translation:
- Active: given it is possible to create many records for a metadata, it is easier to check or uncheck this field to inform which metadata must be considered for the next translations. A priori, only one of them must be checked.
- Email: provide an email address to be warned with general informations when the batch process of translations is finished.
- Fields Map: provide a JSON-like with the fields named after Source Object Fields, and values named after the correspondent Target Object Fields. This JSON can be improved with instrucitons to make the whole process easier.
- Last Value: This field is auto populated after each translation process, with the last LastModifiedDate value among all source objects translated in the last time.
- Unique Field: this field must be populated with the field name that uniquely correlates source and target objects. It is used for further updates purposes.
3) Created at least one custom metadata type record and activate it.

### Pending:
- Update the Last Value field on metadata during the batch flow.





# Salesforce App

This guide helps Salesforce developers who are new to Visual Studio Code go from zero to a deployed app using Salesforce Extensions for VS Code and Salesforce CLI.

## Part 1: Choosing a Development Model

There are two types of developer processes or models supported in Salesforce Extensions for VS Code and Salesforce CLI. These models are explained below. Each model offers pros and cons and is fully supported.

### Package Development Model

The package development model allows you to create self-contained applications or libraries that are deployed to your org as a single package. These packages are typically developed against source-tracked orgs called scratch orgs. This development model is geared toward a more modern type of software development process that uses org source tracking, source control, and continuous integration and deployment.

If you are starting a new project, we recommend that you consider the package development model. To start developing with this model in Visual Studio Code, see [Package Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/package-development-model). For details about the model, see the [Package Development Model](https://trailhead.salesforce.com/en/content/learn/modules/sfdx_dev_model) Trailhead module.

If you are developing against scratch orgs, use the command `SFDX: Create Project` (VS Code) or `sfdx force:project:create` (Salesforce CLI)  to create your project. If you used another command, you might want to start over with that command.

When working with source-tracked orgs, use the commands `SFDX: Push Source to Org` (VS Code) or `sfdx force:source:push` (Salesforce CLI) and `SFDX: Pull Source from Org` (VS Code) or `sfdx force:source:pull` (Salesforce CLI). Do not use the `Retrieve` and `Deploy` commands with scratch orgs.

### Org Development Model

The org development model allows you to connect directly to a non-source-tracked org (sandbox, Developer Edition (DE) org, Trailhead Playground, or even a production org) to retrieve and deploy code directly. This model is similar to the type of development you have done in the past using tools such as Force.com IDE or MavensMate.

To start developing with this model in Visual Studio Code, see [Org Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/org-development-model). For details about the model, see the [Org Development Model](https://trailhead.salesforce.com/content/learn/modules/org-development-model) Trailhead module.

If you are developing against non-source-tracked orgs, use the command `SFDX: Create Project with Manifest` (VS Code) or `sfdx force:project:create --manifest` (Salesforce CLI) to create your project. If you used another command, you might want to start over with this command to create a Salesforce DX project.

When working with non-source-tracked orgs, use the commands `SFDX: Deploy Source to Org` (VS Code) or `sfdx force:source:deploy` (Salesforce CLI) and `SFDX: Retrieve Source from Org` (VS Code) or `sfdx force:source:retrieve` (Salesforce CLI). The `Push` and `Pull` commands work only on orgs with source tracking (scratch orgs).

## The `sfdx-project.json` File

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

The most important parts of this file for getting started are the `sfdcLoginUrl` and `packageDirectories` properties.

The `sfdcLoginUrl` specifies the default login URL to use when authorizing an org.

The `packageDirectories` filepath tells VS Code and Salesforce CLI where the metadata files for your project are stored. You need at least one package directory set in your file. The default setting is shown below. If you set the value of the `packageDirectories` property called `path` to `force-app`, by default your metadata goes in the `force-app` directory. If you want to change that directory to something like `src`, simply change the `path` value and make sure the directory you’re pointing to exists.

```json
"packageDirectories" : [
    {
      "path": "force-app",
      "default": true
    }
]
```

## Part 2: Working with Source

For details about developing against scratch orgs, see the [Package Development Model](https://trailhead.salesforce.com/en/content/learn/modules/sfdx_dev_model) module on Trailhead or [Package Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/package-development-model).

For details about developing against orgs that don’t have source tracking, see the [Org Development Model](https://trailhead.salesforce.com/content/learn/modules/org-development-model) module on Trailhead or [Org Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/org-development-model).

## Part 3: Deploying to Production

Don’t deploy your code to production directly from Visual Studio Code. The deploy and retrieve commands do not support transactional operations, which means that a deployment can fail in a partial state. Also, the deploy and retrieve commands don’t run the tests needed for production deployments. The push and pull commands are disabled for orgs that don’t have source tracking, including production orgs.

Deploy your changes to production using [packaging](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp.htm) or by [converting your source](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_source.htm#cli_reference_convert) into metadata format and using the [metadata deploy command](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_mdapi.htm#cli_reference_deploy).