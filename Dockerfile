FROM mcr.microsoft.com/powershell:latest

#working directory
WORKDIR /app

#Copy the PowerShell Fibonacci script
COPY fibonacci.ps1 /app/

ENV n=10
EXPOSE 8080

CMD ["pwsh", "-Command", "/app/fibonacci.ps1 $env:n"]
