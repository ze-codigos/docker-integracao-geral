-- Generated schema from XML metadata (Superset of Nexus schema)
-- Improved with SERIAL PRIMARY KEY, standard defaults and constraints

CREATE TABLE IF NOT EXISTS tbe_admin_usuario (
    id_admin SERIAL PRIMARY KEY,
    nome character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    id_firebase character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp without time zone
);

CREATE INDEX IF NOT EXISTS idx_tbe_admin_usuario_id_admin ON tbe_admin_usuario(id_admin);
CREATE INDEX IF NOT EXISTS idx_tbe_admin_usuario_id_firebase ON tbe_admin_usuario(id_firebase);

CREATE TABLE IF NOT EXISTS tbe_agencia (
    id_agencia SERIAL PRIMARY KEY,
    nome character varying(255) NOT NULL,
    cnpj character varying(20),
    link_logo text,
    endereco text,
    cor character varying(255),
    chave_pix text,
    banco character varying(255),
    banco_pix character varying(255),
    nome_recebedor_pix character varying(255),
    conta_bancaria character varying(50),
    agencia_bancaria character varying(50)
);


CREATE TABLE IF NOT EXISTS tbe_agencia_status (
    id_status SERIAL PRIMARY KEY,
    nome_status character varying(50) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_tbe_agencia_status_id_status ON tbe_agencia_status(id_status);

CREATE TABLE IF NOT EXISTS tbe_agency_overview (
    id_overview SERIAL PRIMARY KEY,
    agency_name character varying(255) NOT NULL,
    total_users integer,
    active_users integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone
);

CREATE INDEX IF NOT EXISTS idx_tbe_agency_overview_id_overview ON tbe_agency_overview(id_overview);

CREATE TABLE IF NOT EXISTS tbe_cadastro (
    id_cadastro SERIAL PRIMARY KEY,
    nome_agencia character varying(255) NOT NULL,
    nome_usuario character varying(255) NOT NULL,
    email_corporativo character varying(255) NOT NULL,
    numero_whats character varying(20),
    como_conheceu character varying(100),
    fatura_mensal character varying(50),
    tipo_agencia character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    observacao text,
    id_representante integer,
    -- KYC / onboarding fields (EmissorAuth cadastro flow)
    status_atual character varying(50),
    cnpj character varying(20),
    dados_cnpj jsonb,
    doc_rg_frente text,
    doc_rg_verso text,
    doc_selfie text,
    cpf_rg character varying(30),
    signing_request_id character varying(255),
    contrato_assinado boolean DEFAULT FALSE,
    data_assinatura timestamp without time zone,
    link_acesso text,
    motivo_negacao text,
    data_criacao timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_tbe_cadastro_id_representante ON tbe_cadastro(id_representante);

CREATE TABLE IF NOT EXISTS tbe_cadastro_status (
    id_historico SERIAL PRIMARY KEY,
    id_cadastro integer NOT NULL,
    id_status integer NOT NULL,
    data_mudanca timestamp without time zone
);

CREATE INDEX IF NOT EXISTS idx_tbe_cadastro_status_id_historico ON tbe_cadastro_status(id_historico);
CREATE INDEX IF NOT EXISTS idx_tbe_cadastro_status_id_cadastro ON tbe_cadastro_status(id_cadastro);
CREATE INDEX IF NOT EXISTS idx_tbe_cadastro_status_id_status ON tbe_cadastro_status(id_status);

CREATE TABLE IF NOT EXISTS tbe_cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome character varying(150) NOT NULL,
    cpf character varying(20) NOT NULL,
    email character varying(150),
    data_nascimento date,
    numero character varying(20),
    id_agencia integer NOT NULL,
    genero character varying(1),
    tipo_passageiro character varying(10),
    doc_type character varying(20),
    doc_digit character varying(10),
    doc_issuing_country character varying(3),
    doc_issuing_date date,
    doc_expiration_date date,
    doc_issuing_organization character varying(20),
    doc_issuing_state character varying(3),
    name_in_document character varying(150),
    residence_country character varying(3),
    CONSTRAINT uc_cpf_agencia UNIQUE (cpf, id_agencia)
);

CREATE INDEX IF NOT EXISTS idx_tbe_cliente_id_agencia ON tbe_cliente(id_agencia);

CREATE TABLE IF NOT EXISTS tbe_conexao (
    id_conexao SERIAL PRIMARY KEY,
    id_segmento integer NOT NULL,
    origem character varying(100) NOT NULL,
    destino character varying(100) NOT NULL,
    data_partida timestamp without time zone NOT NULL,
    data_chegada timestamp without time zone,
    duracao interval
);

CREATE INDEX IF NOT EXISTS idx_tbe_conexao_id_segmento ON tbe_conexao(id_segmento);

CREATE TABLE IF NOT EXISTS tbe_goal_manual_adjustment (
    id_adjustment SERIAL PRIMARY KEY,
    goal_key text NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    metric text NOT NULL,
    amount numeric NOT NULL,
    updated_at timestamp without time zone,
    updated_by integer
);

CREATE INDEX IF NOT EXISTS idx_tbe_goal_manual_adjustment_id_adjustment ON tbe_goal_manual_adjustment(id_adjustment);

CREATE TABLE IF NOT EXISTS tbe_passagem (
    id_passagem SERIAL PRIMARY KEY,
    classe character varying(50),
    data_ida timestamp without time zone NOT NULL,
    data_volta timestamp without time zone,
    origem character varying(100) NOT NULL,
    destino character varying(100) NOT NULL,
    data_criacao_reserva timestamp without time zone,
    data_limite_emissao timestamp without time zone,
    preco numeric,
    companhia_aerea character varying(100),
    localizador character varying(50),
    id_agencia integer NOT NULL,
    id_usuario integer NOT NULL,
    status_emissao character varying(50),
    link_pagamento text,
    preco_sem_taxa double precision,
    rav_percentage integer,
    pago_agencia boolean NOT NULL DEFAULT FALSE,
    provider_booking_token text,
    priced_rate_token text,
    priced_rate_token_return text,
    confirmation_ticket_id character varying(40)
);

CREATE INDEX IF NOT EXISTS idx_tbe_passagem_id_agencia ON tbe_passagem(id_agencia);
CREATE INDEX IF NOT EXISTS idx_tbe_passagem_id_usuario ON tbe_passagem(id_usuario);

CREATE TABLE IF NOT EXISTS tbe_passagem_cliente (
    id_passagem_cliente SERIAL PRIMARY KEY,
    id_passagem integer NOT NULL,
    id_cliente integer NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_tbe_passagem_cliente_id_passagem ON tbe_passagem_cliente(id_passagem);
CREATE INDEX IF NOT EXISTS idx_tbe_passagem_cliente_id_cliente ON tbe_passagem_cliente(id_cliente);

CREATE TABLE IF NOT EXISTS tbe_permissao (
    id_permissao SERIAL PRIMARY KEY,
    nome_permissao character varying(255) NOT NULL
);


CREATE TABLE IF NOT EXISTS tbe_representante (
    id_representante SERIAL PRIMARY KEY,
    nome_representante character varying(255) NOT NULL,
    ativo boolean NOT NULL DEFAULT FALSE
);


CREATE TABLE IF NOT EXISTS tbe_segmento (
    id_segmento SERIAL PRIMARY KEY,
    data_partida timestamp without time zone NOT NULL,
    data_chegada timestamp without time zone NOT NULL,
    origem character varying(100) NOT NULL,
    destino character varying(100) NOT NULL,
    duracao interval,
    bagagem_mao boolean DEFAULT FALSE,
    bolsa_mao boolean DEFAULT FALSE,
    bagagem_despachada boolean DEFAULT FALSE,
    bagagem_despachada_quantidade integer DEFAULT 0,
    lugar_reservado boolean DEFAULT FALSE,
    programa_fidelidade boolean DEFAULT FALSE,
    reembolsavel boolean DEFAULT FALSE,
    trocar boolean DEFAULT FALSE,
    espaco_extra boolean DEFAULT FALSE,
    id_passagem integer NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_tbe_segmento_id_passagem ON tbe_segmento(id_passagem);

CREATE TABLE IF NOT EXISTS tbe_usuario (
    id_usuario SERIAL PRIMARY KEY,
    nome character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    id_firebase character varying(128),
    first_login timestamp without time zone
);

CREATE INDEX IF NOT EXISTS idx_tbe_usuario_id_firebase ON tbe_usuario(id_firebase);

CREATE TABLE IF NOT EXISTS tbe_usuario_agencia (
    id_ua SERIAL PRIMARY KEY,
    id_usuario integer NOT NULL,
    id_agencia integer NOT NULL,
    is_default boolean NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_tbe_usuario_agencia_id_ua ON tbe_usuario_agencia(id_ua);
CREATE INDEX IF NOT EXISTS idx_tbe_usuario_agencia_id_usuario ON tbe_usuario_agencia(id_usuario);
CREATE INDEX IF NOT EXISTS idx_tbe_usuario_agencia_id_agencia ON tbe_usuario_agencia(id_agencia);

CREATE TABLE IF NOT EXISTS tbe_usuario_permissao (
    id_u_p SERIAL PRIMARY KEY,
    id_usuario integer NOT NULL,
    id_permissao integer NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_tbe_usuario_permissao_id_u_p ON tbe_usuario_permissao(id_u_p);
CREATE INDEX IF NOT EXISTS idx_tbe_usuario_permissao_id_usuario ON tbe_usuario_permissao(id_usuario);
CREATE INDEX IF NOT EXISTS idx_tbe_usuario_permissao_id_permissao ON tbe_usuario_permissao(id_permissao);

-- ============================================================================
-- Tabelas de Encurtamento de Tokens (Nexus)
-- ============================================================================

CREATE TABLE IF NOT EXISTS tbe_rate_token_short_url (
    id_short_url SERIAL PRIMARY KEY,
    short_code VARCHAR(20) NOT NULL UNIQUE,
    priced_rate_token TEXT NOT NULL,
    priced_rate_token_return TEXT,
    agencia_id INTEGER NOT NULL DEFAULT 3,
    usuario_id INTEGER NOT NULL DEFAULT 3,
    telefone VARCHAR(20),
    adults SMALLINT NOT NULL DEFAULT 1,
    children SMALLINT NOT NULL DEFAULT 0,
    babies SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    preco_total NUMERIC(12,2),
    passagens_data JSON
);

CREATE INDEX IF NOT EXISTS idx_short_code ON tbe_rate_token_short_url(short_code);
CREATE INDEX IF NOT EXISTS idx_short_url_expires_at ON tbe_rate_token_short_url(expires_at);

CREATE TABLE IF NOT EXISTS tbe_booking_token_short_url (
    id_short_url SERIAL PRIMARY KEY,
    short_code VARCHAR(20) NOT NULL UNIQUE,
    booking_token TEXT NOT NULL,
    agency_id INTEGER NOT NULL,
    temp_jwt TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_booking_short_code ON tbe_booking_token_short_url(short_code);
CREATE INDEX IF NOT EXISTS idx_booking_short_url_expires_at ON tbe_booking_token_short_url(expires_at);

-- Foreign Key Constraints
ALTER TABLE tbe_cadastro ADD CONSTRAINT fk_tbe_cadastro_id_representante FOREIGN KEY (id_representante) REFERENCES tbe_representante(id_representante) ON DELETE CASCADE;
ALTER TABLE tbe_cadastro_status ADD CONSTRAINT fk_tbe_cadastro_status_id_cadastro FOREIGN KEY (id_cadastro) REFERENCES tbe_cadastro(id_cadastro) ON DELETE CASCADE;
ALTER TABLE tbe_cliente ADD CONSTRAINT fk_tbe_cliente_id_agencia FOREIGN KEY (id_agencia) REFERENCES tbe_agencia(id_agencia) ON DELETE CASCADE;
ALTER TABLE tbe_conexao ADD CONSTRAINT fk_tbe_conexao_id_segmento FOREIGN KEY (id_segmento) REFERENCES tbe_segmento(id_segmento) ON DELETE CASCADE;
ALTER TABLE tbe_passagem ADD CONSTRAINT fk_tbe_passagem_id_agencia FOREIGN KEY (id_agencia) REFERENCES tbe_agencia(id_agencia) ON DELETE CASCADE;
ALTER TABLE tbe_passagem ADD CONSTRAINT fk_tbe_passagem_id_usuario FOREIGN KEY (id_usuario) REFERENCES tbe_usuario(id_usuario) ON DELETE CASCADE;
ALTER TABLE tbe_passagem_cliente ADD CONSTRAINT fk_tbe_passagem_cliente_id_passagem FOREIGN KEY (id_passagem) REFERENCES tbe_passagem(id_passagem) ON DELETE CASCADE;
ALTER TABLE tbe_passagem_cliente ADD CONSTRAINT fk_tbe_passagem_cliente_id_cliente FOREIGN KEY (id_cliente) REFERENCES tbe_cliente(id_cliente) ON DELETE CASCADE;
ALTER TABLE tbe_segmento ADD CONSTRAINT fk_tbe_segmento_id_passagem FOREIGN KEY (id_passagem) REFERENCES tbe_passagem(id_passagem) ON DELETE CASCADE;
ALTER TABLE tbe_usuario_agencia ADD CONSTRAINT fk_tbe_usuario_agencia_id_usuario FOREIGN KEY (id_usuario) REFERENCES tbe_usuario(id_usuario) ON DELETE CASCADE;
ALTER TABLE tbe_usuario_agencia ADD CONSTRAINT fk_tbe_usuario_agencia_id_agencia FOREIGN KEY (id_agencia) REFERENCES tbe_agencia(id_agencia) ON DELETE CASCADE;
ALTER TABLE tbe_usuario_permissao ADD CONSTRAINT fk_tbe_usuario_permissao_id_usuario FOREIGN KEY (id_usuario) REFERENCES tbe_usuario(id_usuario) ON DELETE CASCADE;
ALTER TABLE tbe_usuario_permissao ADD CONSTRAINT fk_tbe_usuario_permissao_id_permissao FOREIGN KEY (id_permissao) REFERENCES tbe_permissao(id_permissao) ON DELETE CASCADE;

-- ============================================================================
-- Rodobus (tbe_bus_*) — normalmente criadas via Alembic, incluídas aqui para
-- garantir schema completo em fresh init
-- ============================================================================

CREATE TABLE IF NOT EXISTS tbe_bus_bookings (
    id VARCHAR PRIMARY KEY,
    provider VARCHAR NOT NULL,
    provider_booking_id VARCHAR,
    rav INTEGER NOT NULL DEFAULT 0,
    status VARCHAR DEFAULT 'draft',
    expires_at TIMESTAMP,
    total_amount FLOAT,
    payment_method VARCHAR,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP,
    id_agencia INTEGER,
    id_usuario INTEGER,
    nome_usuario VARCHAR,
    origem VARCHAR,
    destino VARCHAR,
    companhia VARCHAR,
    data_partida TIMESTAMP,
    data_volta TIMESTAMP,
    checkout_url VARCHAR,
    comissao FLOAT,
    confirmation_ticket_id VARCHAR(40)
);

CREATE INDEX IF NOT EXISTS ix_tbe_bus_bookings_provider_booking
    ON tbe_bus_bookings (provider, provider_booking_id);

CREATE TABLE IF NOT EXISTS tbe_bus_booking_travels (
    id SERIAL PRIMARY KEY,
    booking_id VARCHAR NOT NULL REFERENCES tbe_bus_bookings(id),
    travel_id VARCHAR NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tbe_bus_booking_passengers (
    id SERIAL PRIMARY KEY,
    booking_travel_id INTEGER NOT NULL REFERENCES tbe_bus_booking_travels(id),
    name VARCHAR NOT NULL,
    birth_date VARCHAR NOT NULL,
    travel_document VARCHAR NOT NULL,
    travel_document_type VARCHAR DEFAULT 'RG',
    cpf VARCHAR,
    cep VARCHAR,
    seat_number VARCHAR,
    connection_seat_number VARCHAR,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tbe_bus_purchases (
    id SERIAL PRIMARY KEY,
    provider_purchase_id VARCHAR NOT NULL,
    booking_id VARCHAR REFERENCES tbe_bus_bookings(id),
    external_id VARCHAR,
    email VARCHAR NOT NULL,
    status VARCHAR NOT NULL,
    total FLOAT NOT NULL,
    payment_method VARCHAR,
    created_at TIMESTAMP DEFAULT now(),
    cancellation_limit_date TIMESTAMP,
    id_agencia INTEGER,
    origem VARCHAR,
    destino VARCHAR,
    companhia VARCHAR,
    data_partida TIMESTAMP,
    rav INTEGER,
    comissao FLOAT,
    confirmation_ticket_id VARCHAR(40),
    buyer_phone VARCHAR(20),
    no_bpe BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS ix_tbe_bus_purchases_provider_purchase
    ON tbe_bus_purchases (provider_purchase_id);
CREATE INDEX IF NOT EXISTS ix_tbe_bus_purchases_external_id
    ON tbe_bus_purchases (external_id);

CREATE TABLE IF NOT EXISTS tbe_bus_passengers (
    id SERIAL PRIMARY KEY,
    purchase_id INTEGER REFERENCES tbe_bus_purchases(id),
    name VARCHAR NOT NULL,
    cpf VARCHAR,
    travel_document VARCHAR,
    seat_number VARCHAR,
    ticket_code VARCHAR,
    bpe_url VARCHAR,
    insurance_cpf VARCHAR,
    insurance_birth_date VARCHAR,
    insurance_cep VARCHAR,
    insurance_voucher VARCHAR,
    cancellation_allowed BOOLEAN DEFAULT FALSE,
    cancellation_fee FLOAT DEFAULT 0.0,
    cancellation_limit_date TIMESTAMP,
    boarding_pass_ticket_id VARCHAR(40)
);

-- Seed Alembic version para que o Rodobus não tente re-executar migrations
CREATE TABLE IF NOT EXISTS alembic_version (
    version_num VARCHAR(32) NOT NULL PRIMARY KEY
);

INSERT INTO alembic_version (version_num)
    VALUES ('k6f7a8b9c0d1')
    ON CONFLICT DO NOTHING;

-- ============================================================================
-- EmissorAuth (agency_ticket_settings, generated_tickets)
-- Normalmente criadas por 'npm run db:setup:dev', incluídas aqui para fresh init
-- ============================================================================

CREATE TABLE IF NOT EXISTS agency_ticket_settings (
    id_agencia INTEGER PRIMARY KEY
        REFERENCES tbe_agencia(id_agencia) ON DELETE CASCADE,
    logo_url TEXT,
    logo_scale NUMERIC(6,3) DEFAULT 1.000,
    auto_crop_logo BOOLEAN DEFAULT TRUE,
    template_oneway_json JSONB,
    template_roundtrip_json JSONB,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_by INTEGER
        REFERENCES tbe_usuario(id_usuario) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS generated_tickets (
    id_ticket UUID PRIMARY KEY,
    id_agencia INTEGER NOT NULL
        REFERENCES tbe_agencia(id_agencia) ON DELETE CASCADE,
    tipo VARCHAR(16) NOT NULL,
    rate_token_ida TEXT NOT NULL,
    rate_token_volta TEXT,
    total_price NUMERIC(14,2),
    pax_adults INTEGER DEFAULT 1,
    pax_children INTEGER DEFAULT 0,
    pax_babies INTEGER DEFAULT 0,
    flight_snapshot JSONB,
    image_base64 TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_generated_tickets_agencia_created
    ON generated_tickets (id_agencia, created_at DESC);

-- ============================================================================
-- EmissorCheckout (checkout_state, pix_transactions, pix_transactions_v2,
--                  insurance_links, jwt_tokens, passageiros_salvos)
-- Normalmente criadas via SQLAlchemy metadata, incluídas aqui para fresh init
-- ============================================================================

CREATE TABLE IF NOT EXISTS checkout_state (
    id SERIAL PRIMARY KEY,
    jwt_token_hash VARCHAR(32) NOT NULL,
    passengers_confirmed BOOLEAN NOT NULL,
    custom_passengers JSONB,
    localizador VARCHAR(30),
    booking_token_reserva TEXT,
    reservation_data JSONB,
    telefone VARCHAR(30),
    short_code VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ix_checkout_state_jwt_token_hash ON checkout_state(jwt_token_hash);
CREATE INDEX IF NOT EXISTS ix_checkout_state_short_code ON checkout_state(short_code);
CREATE INDEX IF NOT EXISTS ix_checkout_state_telefone ON checkout_state(telefone);

CREATE TABLE IF NOT EXISTS pix_transactions (
    id SERIAL PRIMARY KEY,
    pix_id VARCHAR(100) NOT NULL,
    jwt_token TEXT NOT NULL,
    amount DOUBLE PRECISION NOT NULL,
    external_id VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    payment_data JSON,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    localizador VARCHAR(100),
    booking_token TEXT,
    paxs JSON
);

CREATE UNIQUE INDEX IF NOT EXISTS ix_pix_transactions_pix_id ON pix_transactions(pix_id);

CREATE TABLE IF NOT EXISTS pix_transactions_v2 (
    id SERIAL PRIMARY KEY,
    pix_id VARCHAR(255) NOT NULL,
    booking_token TEXT NOT NULL,
    agency_id INTEGER NOT NULL,
    amount_cents INTEGER NOT NULL,
    external_id VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE,
    payment_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    transaction_type VARCHAR(50) NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ix_pix_transactions_v2_pix_id ON pix_transactions_v2(pix_id);
CREATE INDEX IF NOT EXISTS ix_pix_transactions_v2_booking_token ON pix_transactions_v2(booking_token);

CREATE TABLE IF NOT EXISTS insurance_links (
    id SERIAL PRIMARY KEY,
    token VARCHAR(32) NOT NULL,
    insurance_data JSONB NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ix_insurance_links_token ON insurance_links(token);

CREATE TABLE IF NOT EXISTS jwt_tokens (
    codigo VARCHAR(12) PRIMARY KEY,
    jwt_token TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE,
    is_tarifado BOOLEAN,
    tarifado_at TIMESTAMP WITH TIME ZONE,
    tarifacao_data JSONB
);

CREATE TABLE IF NOT EXISTS passageiros_salvos (
    id SERIAL PRIMARY KEY,
    telefone_dono VARCHAR(30) NOT NULL,
    nome VARCHAR(200) NOT NULL,
    cpf VARCHAR(20),
    email VARCHAR(200),
    data_nascimento VARCHAR(20),
    gender VARCHAR(10),
    passenger_type VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_passageiros_salvos_telefone_dono ON passageiros_salvos(telefone_dono);
CREATE UNIQUE INDEX IF NOT EXISTS idx_passageiros_salvos_telefone_cpf
    ON passageiros_salvos(telefone_dono, cpf) WHERE cpf IS NOT NULL;

-- ============================================================================
-- HeroSeguros (hero_insurance_emissions, hero_insurance_passengers)
-- ============================================================================

CREATE TABLE IF NOT EXISTS hero_insurance_emissions (
    id SERIAL PRIMARY KEY,
    order_id VARCHAR(64),
    operation VARCHAR(64) NOT NULL,
    agencia_id INTEGER NOT NULL,
    usuario_id INTEGER NOT NULL,
    plan_id INTEGER NOT NULL,
    plan_name VARCHAR(255),
    destiny_group VARCHAR(100) NOT NULL,
    departure VARCHAR(20) NOT NULL,
    arrival VARCHAR(20) NOT NULL,
    passenger_count INTEGER NOT NULL,
    amount NUMERIC(12,2),
    commission_rate NUMERIC(5,2) NOT NULL,
    discount_percentage NUMERIC(5,2) DEFAULT 0 NOT NULL,
    platform_commission NUMERIC(5,2) NOT NULL,
    agency_commission NUMERIC(5,2) NOT NULL,
    platform_commission_value NUMERIC(12,2),
    agency_commission_value NUMERIC(12,2),
    status VARCHAR(20) DEFAULT 'emitted' NOT NULL,
    payment_link TEXT,
    checkout_link TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS hero_insurance_passengers (
    id SERIAL PRIMARY KEY,
    emission_id INTEGER NOT NULL REFERENCES hero_insurance_emissions(id),
    name VARCHAR(200) NOT NULL,
    doc_type VARCHAR(20) NOT NULL,
    doc_number VARCHAR(30) NOT NULL,
    email VARCHAR(200),
    ticket VARCHAR(64),
    pdf_url TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

-- ============================================================================
-- Ticket Delivery (tbe_tickets)
-- Normalmente criada via Alembic (ticket-delivery), incluída aqui para fresh init
-- ============================================================================

CREATE TABLE IF NOT EXISTS tbe_tickets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tipo VARCHAR(30) NOT NULL,
    id_agencia INTEGER NOT NULL,
    gcs_path VARCHAR(500) NOT NULL,
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_tbe_tickets_id_agencia ON tbe_tickets(id_agencia);
CREATE INDEX IF NOT EXISTS idx_tbe_tickets_tipo ON tbe_tickets(tipo);

-- Seed Alembic version for ticket-delivery so it won't re-run migrations
CREATE TABLE IF NOT EXISTS alembic_version_ticket_delivery (
    version_num VARCHAR(32) NOT NULL PRIMARY KEY
);

INSERT INTO alembic_version_ticket_delivery (version_num)
    VALUES ('001')
    ON CONFLICT DO NOTHING;

-- ============================================================================
-- oficial-wpp-api (WhatsApp gateway — conversations, messages, bot state)
-- Criadas via pg Pool no serviço TypeScript
-- ============================================================================

CREATE TABLE IF NOT EXISTS conversations (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(255) NOT NULL,
    vendedor VARCHAR(100),
    last_message TEXT,
    last_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unread_count INTEGER DEFAULT 0,
    profile_photo_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_conversations_numero ON conversations(numero);

CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    numero VARCHAR(50) NOT NULL,
    message_id VARCHAR(255) UNIQUE NOT NULL,
    whatsapp_id VARCHAR(255),
    tipo VARCHAR(50) NOT NULL,
    texto TEXT,
    nome VARCHAR(255),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_carousel BOOLEAN DEFAULT FALSE,
    carousel_cards JSONB,
    is_template BOOLEAN DEFAULT FALSE,
    template_name VARCHAR(255),
    is_flow BOOLEAN DEFAULT FALSE,
    is_bot_blocked BOOLEAN DEFAULT FALSE,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_numero ON messages(numero);

CREATE TABLE IF NOT EXISTS bot_blocked (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(50) UNIQUE NOT NULL,
    blocked BOOLEAN DEFAULT FALSE,
    blocked_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bot_blocked_numero_blocked ON bot_blocked(numero) WHERE blocked = TRUE;

CREATE TABLE IF NOT EXISTS vendedores_mapping (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nome_vendedor VARCHAR(100) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_vendedores_mapping_email ON vendedores_mapping(email);

-- ============================================================================
-- bot/agente (conversational AI agent — prompts, tools, state, followup)
-- Criadas via SQLAlchemy metadata no serviço Python
-- ============================================================================

CREATE TABLE IF NOT EXISTS conversas (
    telefone VARCHAR(255) PRIMARY KEY,
    nome VARCHAR(255),
    create_time DATE,
    trava_bot INTEGER
);

CREATE TABLE IF NOT EXISTS mensagens (
    id INTEGER PRIMARY KEY,
    telefone VARCHAR(255),
    create_time VARCHAR(255),
    content VARCHAR(255),
    author VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS prompts (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    conteudo TEXT NOT NULL,
    descricao TEXT,
    versao INTEGER DEFAULT 1,
    ativo BOOLEAN DEFAULT TRUE,
    categoria VARCHAR(50),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    criado_por VARCHAR(100),
    tags TEXT[]
);

CREATE TABLE IF NOT EXISTS tools (
    id SERIAL PRIMARY KEY,
    nome_tool VARCHAR(100) NOT NULL UNIQUE,
    tipo_agente VARCHAR(50) NOT NULL,
    descricao TEXT NOT NULL,
    mensagem TEXT NOT NULL,
    author VARCHAR(100),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_tools_nome_tool ON tools(nome_tool);
CREATE INDEX IF NOT EXISTS idx_tools_tipo_agente ON tools(tipo_agente);
CREATE INDEX IF NOT EXISTS idx_tools_ativo ON tools(ativo);

CREATE TABLE IF NOT EXISTS saved_passenger_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero VARCHAR(255) NOT NULL,
    passenger_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_saved_passenger_data_numero ON saved_passenger_data(numero);

CREATE TABLE IF NOT EXISTS templates (
    id SERIAL PRIMARY KEY,
    template_name VARCHAR(200) NOT NULL UNIQUE,
    type VARCHAR(50) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    is_carrossel INTEGER DEFAULT 0,
    num_cards INTEGER,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS campaigns (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    message_template TEXT NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS mensagens_fup (
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    tempo_disparo INTEGER NOT NULL,
    mensagem TEXT NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_mensagens_fup_tipo ON mensagens_fup(tipo);

CREATE TABLE IF NOT EXISTS followup_settings (
    id INTEGER PRIMARY KEY DEFAULT 1,
    habilitado BOOLEAN NOT NULL DEFAULT TRUE,
    usar_allowlist BOOLEAN NOT NULL DEFAULT FALSE,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS followup_allowed_phones (
    id SERIAL PRIMARY KEY,
    telefone VARCHAR(30) NOT NULL UNIQUE,
    descricao VARCHAR(100),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS links_passagens_enviadas (
    telefone VARCHAR(255) PRIMARY KEY NOT NULL,
    ida VARCHAR(255),
    volta VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS system_settings (
    id SERIAL PRIMARY KEY,
    chave VARCHAR(100) NOT NULL UNIQUE,
    valor_int INTEGER,
    valor_string VARCHAR(500),
    valor_bool BOOLEAN,
    valor_float FLOAT,
    tipo_dado VARCHAR(20) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(50),
    ativo BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_por VARCHAR(100)
);

-- ============================================================================
-- bot/alertas_v2 (price alert subscriptions)
-- Criadas via SQLAlchemy metadata no serviço Python
-- ============================================================================

CREATE TABLE IF NOT EXISTS alertas (
    id SERIAL PRIMARY KEY,
    telefone VARCHAR(20),
    iata_origem VARCHAR(3) NOT NULL,
    iata_destino VARCHAR(3) NOT NULL,
    cidade_origem VARCHAR(100),
    cidade_destino VARCHAR(100),
    adults INTEGER NOT NULL DEFAULT 1,
    children INTEGER NOT NULL DEFAULT 0,
    babies INTEGER NOT NULL DEFAULT 0,
    class_service INTEGER NOT NULL DEFAULT 1,
    rav_percentage INTEGER NOT NULL DEFAULT 2,
    sql_filter_query TEXT,
    filters_json TEXT,
    preco_alvo_escolhido_na_criacao FLOAT,
    preco_referencia_para_envio_dos_alertas FLOAT,
    percentual_desconto FLOAT NOT NULL DEFAULT 5.0,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_alertas_id ON alertas(id);
CREATE INDEX IF NOT EXISTS idx_alertas_telefone ON alertas(telefone);
CREATE INDEX IF NOT EXISTS idx_alertas_deleted ON alertas(deleted);

CREATE TABLE IF NOT EXISTS datas_viagem (
    id SERIAL PRIMARY KEY,
    alerta_id INTEGER NOT NULL REFERENCES alertas(id) ON DELETE CASCADE,
    data_ida TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    data_volta TIMESTAMP WITHOUT TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_datas_viagem_id ON datas_viagem(id);

CREATE TABLE IF NOT EXISTS voos_para_filtros_alertas (
    id SERIAL PRIMARY KEY,
    numero_telefone TEXT NOT NULL,
    preco_total FLOAT,
    ratetoken_ida TEXT,
    ratetoken_volta TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    ida_airline TEXT,
    ida_departure_time TEXT,
    ida_departure_location TEXT,
    ida_arrival_location TEXT,
    ida_arrival_time TEXT,
    ida_tax FLOAT,
    ida_total_tax FLOAT,
    ida_qnt_stop INTEGER,
    ida_escale TEXT,
    ida_stops TEXT,
    ida_total_flight_duration TEXT,
    ida_miles FLOAT,
    ida_pares_escalas INTEGER,
    ida_escala TEXT,
    ida_bagagem_despachada_inclusa BOOLEAN,
    ida_bagagem_despachada_quantidade INTEGER,
    ida_tempo_parada_maior_minutos INTEGER,
    volta_airline TEXT,
    volta_departure_time TEXT,
    volta_departure_location TEXT,
    volta_arrival_location TEXT,
    volta_arrival_time TEXT,
    volta_tax FLOAT,
    volta_total_tax FLOAT,
    volta_qnt_stop INTEGER,
    volta_escale TEXT,
    volta_stops TEXT,
    volta_total_flight_duration TEXT,
    volta_miles FLOAT,
    volta_pares_escalas INTEGER,
    volta_escala TEXT,
    volta_bagagem_despachada_inclusa BOOLEAN,
    volta_bagagem_despachada_quantidade INTEGER,
    volta_tempo_parada_maior_minutos INTEGER,
    class_service INTEGER
);

CREATE INDEX IF NOT EXISTS idx_voos_filtros_alertas_telefone ON voos_para_filtros_alertas(numero_telefone);

CREATE TABLE IF NOT EXISTS voos_para_filtros_alertas_criacao (
    id SERIAL PRIMARY KEY,
    numero_telefone TEXT NOT NULL,
    preco_total FLOAT,
    ratetoken_ida TEXT,
    ratetoken_volta TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    ida_airline TEXT,
    ida_departure_time TEXT,
    ida_departure_location TEXT,
    ida_arrival_location TEXT,
    ida_arrival_time TEXT,
    ida_tax FLOAT,
    ida_total_tax FLOAT,
    ida_qnt_stop INTEGER,
    ida_escale TEXT,
    ida_stops TEXT,
    ida_total_flight_duration TEXT,
    ida_miles FLOAT,
    ida_pares_escalas INTEGER,
    ida_escala TEXT,
    ida_bagagem_despachada_inclusa BOOLEAN,
    ida_bagagem_despachada_quantidade INTEGER,
    ida_tempo_parada_maior_minutos INTEGER,
    volta_airline TEXT,
    volta_departure_time TEXT,
    volta_departure_location TEXT,
    volta_arrival_location TEXT,
    volta_arrival_time TEXT,
    volta_tax FLOAT,
    volta_total_tax FLOAT,
    volta_qnt_stop INTEGER,
    volta_escale TEXT,
    volta_stops TEXT,
    volta_total_flight_duration TEXT,
    volta_miles FLOAT,
    volta_pares_escalas INTEGER,
    volta_escala TEXT,
    volta_bagagem_despachada_inclusa BOOLEAN,
    volta_bagagem_despachada_quantidade INTEGER,
    volta_tempo_parada_maior_minutos INTEGER,
    class_service INTEGER
);

CREATE INDEX IF NOT EXISTS idx_voos_filtros_alertas_criacao_telefone ON voos_para_filtros_alertas_criacao(numero_telefone);

-- ============================================================================
-- bot/cupons (discount coupon system)
-- Criadas via SQLAlchemy metadata no serviço Python
-- ============================================================================

CREATE TABLE IF NOT EXISTS cupons (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(200) NOT NULL,
    dono VARCHAR(100) NOT NULL,
    expiracao TIMESTAMP,
    uso_maximo INTEGER,
    uso_atual INTEGER NOT NULL DEFAULT 0,
    valor_desconto_percentual INTEGER NOT NULL DEFAULT 2,
    status VARCHAR(20) NOT NULL DEFAULT 'ATIVO',
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_cupons_codigo ON cupons(codigo);

CREATE TABLE IF NOT EXISTS cupons_tokens (
    id SERIAL PRIMARY KEY,
    telefone VARCHAR(20) NOT NULL,
    origem VARCHAR(3) NOT NULL,
    destino VARCHAR(3) NOT NULL,
    hora_partida VARCHAR(20) NOT NULL,
    hora_volta VARCHAR(20) DEFAULT '',
    companhia VARCHAR(20) DEFAULT '',
    class_service VARCHAR(20) DEFAULT '',
    fare_family VARCHAR(50) DEFAULT '',
    preco_total_original FLOAT NOT NULL,
    tax FLOAT NOT NULL,
    rate_token_ida TEXT NOT NULL,
    rate_token_volta TEXT,
    booking_token_ida TEXT NOT NULL,
    booking_token_volta TEXT,
    preco_rav_zero FLOAT NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_expiracao TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_cupons_tokens_telefone ON cupons_tokens(telefone);

CREATE TABLE IF NOT EXISTS cupom_usage_history (
    id SERIAL PRIMARY KEY,
    cupom_id INTEGER NOT NULL REFERENCES cupons(id),
    cupom_codigo VARCHAR(50) NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    origem VARCHAR(10) NOT NULL,
    destino VARCHAR(10) NOT NULL,
    data_ida VARCHAR(50) NOT NULL,
    data_volta VARCHAR(50),
    companhia VARCHAR(50),
    preco_original NUMERIC(10, 2) NOT NULL,
    preco_com_desconto NUMERIC(10, 2) NOT NULL,
    valor_desconto NUMERIC(10, 2) NOT NULL,
    qtd_passageiros INTEGER DEFAULT 1,
    ip_address VARCHAR(45),
    user_agent TEXT,
    data_uso TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_cupom_usage_history_cupom_codigo ON cupom_usage_history(cupom_codigo);
CREATE INDEX IF NOT EXISTS idx_cupom_usage_history_telefone ON cupom_usage_history(telefone);
CREATE INDEX IF NOT EXISTS idx_cupom_usage_history_data_uso ON cupom_usage_history(data_uso);

-- ──────────────────────────────────────────────────────────────────────
-- CRM AUTH TABLES (crm/auth service)
-- ──────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS roles (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS usuarios (
    id          SERIAL PRIMARY KEY,
    username    VARCHAR(255) NOT NULL,
    email       VARCHAR(255) NOT NULL UNIQUE,
    password    VARCHAR(255),
    auth_method VARCHAR(10)  NOT NULL DEFAULT 'email',
    genero      INTEGER
);

CREATE TABLE IF NOT EXISTS usuarios_roles (
    usuarios_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    role_id     INTEGER NOT NULL REFERENCES roles(id)    ON DELETE CASCADE,
    PRIMARY KEY (usuarios_id, role_id)
);

CREATE TABLE IF NOT EXISTS verification_codes (
    id         SERIAL PRIMARY KEY,
    email      VARCHAR(255) NOT NULL,
    username   VARCHAR(255) NOT NULL,
    password   VARCHAR(255) NOT NULL,
    code       VARCHAR(6)   NOT NULL,
    code_type  VARCHAR(30),
    expires_at TIMESTAMP    NOT NULL,
    extra_data JSONB,
    created_at TIMESTAMP    DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_verification_codes_email ON verification_codes(email);
