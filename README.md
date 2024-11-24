Please adjust the workspace path as required. 


1. Import-Module .\kla\DockerHelper.psm1

2. Copy-Prerequisites -Path ".\kla\" -ComputerName "TestVM" -Destination "C:\remoteDir\"
    Mandatory parameters:
        -ComputerName <String> (name of a remote computer)
        -Path <String[]> (local path(s) where to copy files from)
        -Destination <String> (local path on a remote host where to copy files)

3. New-BuildDockerImage -Dockerfile .\kla\Dockerfile -Tag "fb:latest" -Context ".\kla\"
    Mandatory parameters: 
        -Dockerfile <String> (path to a Dockerfile, which is used for building an image)
        -Tag <String> (Docker image name)
        -Context <String> (path to Docker context directory)
    Optional parameteres:
        -ComputerName <String> (name of a computer, where Docker is installed)

4. Start-RunDockerContainer -ImageName "fb" -DockerParams @("-p", "8080:8080") -n 1000 -tag "fb:latest"
    Mandatory parameters:
        -ImageName <String>
    Optional parameters:
        -ComputerName <String>
        -DockerParams <String[]> 
        
Notes:
[I understand, porting is not required here, its just an example to use DockerParams.]
[Also func names are changed from the ones requested due to unapproved verb usages.]

Thank you. 

Regards 
Bikash Tripathy

