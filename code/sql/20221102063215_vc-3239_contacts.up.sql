CREATE TABLE IF NOT EXISTS api_clients.user_favorite_contacts
(
	user_id    uuid         NOT NULL,
	contact_id uuid         NOT NULL,
-- 	org_id     uuid         NOT NULL,
	note       varchar(255) NOT NULL default '',

	CONSTRAINT users_fts_user_id FOREIGN KEY (user_id)
		REFERENCES api_clients.users (id) MATCH SIMPLE
		ON UPDATE NO ACTION
		ON DELETE CASCADE
		NOT VALID,

	CONSTRAINT users_fts_org_id FOREIGN KEY (org_id)
		REFERENCES api_clients.organizations (id) MATCH SIMPLE
		ON UPDATE NO ACTION
		ON DELETE CASCADE
		NOT VALID
);

COMMENT ON TABLE api_clients.user_favorite_contacts IS 'Список избранных контактов пользователя';
COMMENT ON COLUMN api_clients.user_favorite_contacts.user_id IS 'Владелец записи';
COMMENT ON COLUMN api_clients.user_favorite_contacts.contact_id IS 'Пользователь, добавленный в избранное';
COMMENT ON COLUMN api_clients.user_favorite_contacts.note IS 'Примечание к избранному контакту';

-- заполнение поля org_id
CREATE OR REPLACE FUNCTION api_clients.user_favorite_contacts_upd_org_id() RETURNS TRIGGER AS
$$
BEGIN
	IF (TG_OP = 'UPDATE') AND (OLD.org_id = NEW.org_id) THEN
		RETURN NEW;
	END IF;

	NEW.org_id = (select organization_id
				  from api_clients.org_domains
				  where id = (select domain_id from api_clients.users where id = NEW.user_id));


	-- 	UPDATE api_clients.user_favorite_contacts
-- 	SET org_id = (select org_id
-- 				  from api_clients.org_domains
-- 				  where id = (select domain_id from api_clients.users where id = NEW.user_id));

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION api_clients.user_favorite_contacts_upd_org_id () IS 'Устанавливает id организации у пользователя, к которой он принадлежит';

-- триггер
CREATE OR REPLACE TRIGGER upd_org_id
	BEFORE INSERT OR UPDATE OF org_id
	ON api_clients.user_favorite_contacts
	FOR EACH ROW
EXECUTE PROCEDURE api_clients.user_favorite_contacts_upd_org_id();

-- триггер
CREATE OR REPLACE TRIGGER upd_user_favorite_contacts_org_id
	BEFORE INSERT OR UPDATE OF org_id
	ON api_clients.user_favorite_contacts
	FOR EACH ROW
EXECUTE PROCEDURE api_clients.user_favorite_contacts_upd_org_id();

COMMENT ON TRIGGER upd_user_favorite_contacts_org_id
	ON api_clients.user_favorite_contacts
	IS 'Обновляет значение org_id у пользователя'
