# Customer Agent Installer

Bootstrap público mínimo para iniciar o onboarding guiado pelo Hermes.

```bash
curl -fsSL https://rrmlima.github.io/customer-agent-installer/install.sh | bash
```

O bootstrap verifica o checksum do instalador versionado, instala/prepara o Hermes, solicita autenticação GitHub para o kit privado e abre a conversa guiada. Não contém credenciais e não faz deploy sem escolhas e aprovações durante o onboarding.

O kit privado e a documentação operacional vivem em `rrmlima/fazer-ai-deploy-standard`.

## Inspeção antes de executar

```bash
curl -fsSLO https://rrmlima.github.io/customer-agent-installer/install.sh
less install.sh
bash install.sh
```

## Segurança

- nenhum token embutido;
- origem versionada e checksum fixo;
- kit operacional privado;
- deploy exige confirmação explícita;
- decisões e estados não guardam secrets.
