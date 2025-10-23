-- Arquivo: ./init-db/init.sql
-- Script de Definição de Dados (DDL) para o Banco de Dados Canoa Bahia CRM/ERP

-- Habilitar a extensão uuid-ossp para gerar UUIDs para IDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tabela USUARIOS
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    telefone_whatsapp VARCHAR(20) UNIQUE NOT NULL, -- UK
    email VARCHAR(255) UNIQUE,
    id_google VARCHAR(255),
    perfil VARCHAR(50) NOT NULL DEFAULT 'Remador', -- Enum: Remador, Leme, Administrador, Financeiro
    plano_id UUID, -- FK para PLANOS, pode ser NULL se não tiver plano
    status_financeiro VARCHAR(50) NOT NULL DEFAULT 'Pendente', -- Enum: Adimplente, Inadimplente, Pendente
    data_cadastro TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    data_ultima_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    cadastro_preenchido BOOLEAN NOT NULL DEFAULT FALSE
);

-- 2. Tabela NUCLEOS
CREATE TABLE nucleos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL UNIQUE,
    endereco TEXT,
    sazonal BOOLEAN NOT NULL DEFAULT FALSE,
    turno_noturno_disponivel BOOLEAN NOT NULL DEFAULT FALSE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 3. Tabela CANOAS
CREATE TABLE canoas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(50) NOT NULL, -- Enum: OC6, V4, etc.
    capacidade_remadores INTEGER NOT NULL,
    nucleo_id UUID NOT NULL, -- FK para NUCLEOS
    status VARCHAR(50) NOT NULL DEFAULT 'Disponível', -- Enum: Disponível, Em Manutenção, Em Uso
    data_ultima_manutencao TIMESTAMP WITH TIME ZONE,
    proxima_manutencao_agendada TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_canoas_nucleos FOREIGN KEY (nucleo_id) REFERENCES nucleos(id)
);

-- 4. Tabela SERVICOS (opcional, para maior granularidade)
CREATE TABLE servicos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome_servico VARCHAR(255) NOT NULL UNIQUE,
    descricao TEXT,
    duracao_padrao_minutos INTEGER NOT NULL,
    permite_extensao BOOLEAN NOT NULL DEFAULT FALSE,
    valor_base_avulso NUMERIC(10, 2)
);

-- 5. Tabela EVENTOS_REMADA
CREATE TABLE eventos_remada (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    tipo_servico_id UUID, -- FK para SERVICOS
    nucleo_id UUID NOT NULL, -- FK para NUCLEOS
    canoa_id UUID NOT NULL, -- FK para CANOAS
    leme_id UUID, -- FK para USUARIOS (Leme)
    data_hora_inicio TIMESTAMP WITH TIME ZONE NOT NULL,
    data_hora_fim TIMESTAMP WITH TIME ZONE NOT NULL,
    min_remadores INTEGER NOT NULL DEFAULT 1,
    max_remadores INTEGER NOT NULL,
    status_evento VARCHAR(50) NOT NULL DEFAULT 'Pendente de confirmação', -- Enum: Pendente de confirmação, Confirmado, Concluído, Cancelado
    criado_por_usuario_id UUID NOT NULL, -- FK para USUARIOS (Administrador)
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    data_ultima_modificacao TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    modificado_por_usuario_id UUID, -- FK para USUARIOS
    data_aviso_confirmacao TIMESTAMP WITH TIME ZONE,
    auto_cancelamento_ativado BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_eventos_servicos FOREIGN KEY (tipo_servico_id) REFERENCES servicos(id),
    CONSTRAINT fk_eventos_nucleos FOREIGN KEY (nucleo_id) REFERENCES nucleos(id),
    CONSTRAINT fk_eventos_canoas FOREIGN KEY (canoa_id) REFERENCES canoas(id),
    CONSTRAINT fk_eventos_leme FOREIGN KEY (leme_id) REFERENCES usuarios(id),
    CONSTRAINT fk_eventos_criador FOREIGN KEY (criado_por_usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_eventos_modificador FOREIGN KEY (modificado_por_usuario_id) REFERENCES usuarios(id)
);

-- 6. Tabela INSCRICOES
CREATE TABLE inscricoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL, -- FK para USUARIOS
    evento_id UUID NOT NULL, -- FK para EVENTOS_REMADA
    data_inscricao TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    compareceu VARCHAR(20) NOT NULL DEFAULT 'N/A', -- Enum: Compareceu, Ausente, N/A
    confirmado_presenca_por_usuario_id UUID, -- FK para USUARIOS
    data_confirmacao_presenca TIMESTAMP WITH TIME ZONE,
    observacoes TEXT,
    CONSTRAINT fk_inscricoes_usuarios FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_inscricoes_eventos FOREIGN KEY (evento_id) REFERENCES eventos_remada(id),
    CONSTRAINT fk_inscricoes_confirmador FOREIGN KEY (confirmado_presenca_por_usuario_id) REFERENCES usuarios(id),
    UNIQUE (usuario_id, evento_id) -- Garante que um usuário só pode se inscrever uma vez no mesmo evento
);

-- 7. Tabela BENS
CREATE TABLE bens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    tipo_bem VARCHAR(50) NOT NULL, -- Enum: Remo, Colete, Canoa, Equipamento, etc.
    numero_serie VARCHAR(100),
    nucleo_id UUID NOT NULL, -- FK para NUCLEOS
    proprietario_tipo VARCHAR(50) NOT NULL DEFAULT 'Clube', -- Enum: Clube, Terceiro
    proprietario_nome VARCHAR(255), -- Nome se proprietario_tipo = 'Terceiro'
    emprestado_para_usuario_id UUID, -- FK para USUARIOS
    emprestado_para_nome_externo VARCHAR(255), -- Nome se emprestado para não-usuário
    data_emprestimo TIMESTAMP WITH TIME ZONE,
    status_emprestimo VARCHAR(50) NOT NULL DEFAULT 'No Clube', -- Enum: No Clube, Emprestado
    data_ultima_inspecao_seguranca TIMESTAMP WITH TIME ZONE,
    validade_inspecao_seguranca TIMESTAMP WITH TIME ZONE,
    observacoes_seguranca TEXT,
    CONSTRAINT fk_bens_nucleos FOREIGN KEY (nucleo_id) REFERENCES nucleos(id),
    CONSTRAINT fk_bens_emprestado_para_usuario FOREIGN KEY (emprestado_para_usuario_id) REFERENCES usuarios(id)
);

-- 8. Tabela SUPERVISORES_EVENTO (Junção N:M para administradores que supervisionam eventos)
CREATE TABLE supervisores_evento (
    usuario_id UUID NOT NULL, -- FK para USUARIOS (Administrador/Leme)
    evento_id UUID NOT NULL, -- FK para EVENTOS_REMADA
    PRIMARY KEY (usuario_id, evento_id), -- Chave primária composta
    CONSTRAINT fk_supervisores_usuarios FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_supervisores_eventos FOREIGN KEY (evento_id) REFERENCES eventos_remada(id)
);

-- 9. Tabela PLANOS
CREATE TABLE planos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome_plano VARCHAR(255) NOT NULL UNIQUE,
    tipo_frequencia VARCHAR(50) NOT NULL, -- Enum: Semanal, Mensal, Trimestral, Semestral, Anual, Avulso
    frequencia_semanal INTEGER, -- Quantidade de vezes por semana (ex: 1, 2, 3)
    valor_base_mensal NUMERIC(10, 2) NOT NULL,
    desconto_fidelidade_percentual NUMERIC(5, 2) DEFAULT 0.00,
    desconto_familia_percentual NUMERIC(5, 2) DEFAULT 0.00,
    descricao TEXT,
    beneficios TEXT,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

-- Adicionar a FK para planos na tabela usuarios depois que planos existir
ALTER TABLE usuarios
ADD CONSTRAINT fk_usuarios_planos FOREIGN KEY (plano_id) REFERENCES planos(id);

-- 10. Tabela PAGAMENTOS
CREATE TABLE pagamentos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL, -- FK para USUARIOS
    referencia_tipo VARCHAR(50) NOT NULL, -- Enum: Plano, Avulso, Evento Específico, Aula Experimental
    referencia_id UUID, -- FK opcional para PLANOS ou EVENTOS_REMADA
    valor_pago NUMERIC(10, 2) NOT NULL,
    metodo_pagamento VARCHAR(50) NOT NULL, -- Enum: Pix, Dinheiro, Cartão Crédito, Cartão Débito, Gympass, Totalpass
    status_pagamento VARCHAR(50) NOT NULL DEFAULT 'Aguardando', -- Enum: Aguardando, Aprovado, Rejeitado, Estornado
    data_pagamento TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    confirmado_por_usuario_id UUID, -- FK para USUARIOS (Administrador/Financeiro)
    data_confirmacao TIMESTAMP WITH TIME ZONE,
    observacoes TEXT,
    CONSTRAINT fk_pagamentos_usuarios FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_pagamentos_confirmador FOREIGN KEY (confirmado_por_usuario_id) REFERENCES usuarios(id)
    -- Considerar adicionar FK para referencia_id se o tipo for PLANO ou EVENTO_REMADA
    -- Por simplicidade, pode-se deixar sem FK se referencia_id pode apontar para tabelas diferentes.
);

-- Índices para otimização de consultas comuns
CREATE INDEX idx_usuarios_telefone_whatsapp ON usuarios (telefone_whatsapp);
CREATE INDEX idx_eventos_remada_data_hora_inicio ON eventos_remada (data_hora_inicio);
CREATE INDEX idx_inscricoes_usuario_evento ON inscricoes (usuario_id, evento_id);
CREATE INDEX idx_bens_nucleo_status ON bens (nucleo_id, status_emprestimo);
CREATE INDEX idx_pagamentos_usuario_status ON pagamentos (usuario_id, status_pagamento);